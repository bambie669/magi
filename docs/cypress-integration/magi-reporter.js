/**
 * Magi QA Reporter for Cypress
 *
 * Trimite rezultatele testelor Cypress către API-ul Magi QA.
 * Format test ID: TC-XXXX (ex: "TC-0001: Login test", "[TC-0042] Verify button")
 *
 * Configurare în cypress.config.js:
 *
 *   const magiReporter = require('./magi-reporter');
 *
 *   module.exports = defineConfig({
 *     e2e: {
 *       setupNodeEvents(on, config) {
 *         magiReporter(on, config);
 *         return config;
 *       }
 *     },
 *     env: {
 *       MAGI_API_URL: 'http://localhost:2507',
 *       MAGI_API_TOKEN: 'your_token_here',
 *
 *       // Option 1: Use existing test run
 *       MAGI_TEST_RUN_ID: '123',
 *
 *       // Option 2: Auto-create test run (use project_id instead of test_run_id)
 *       MAGI_PROJECT_ID: '15',
 *       MAGI_RUN_NAME: 'My Custom Run Name',  // Optional, defaults to "Cypress Run - YYYY-MM-DD"
 *
 *       MAGI_AUTO_CREATE: true  // Auto-create missing test cases
 *     }
 *   });
 */

const https = require('https');
const http = require('http');

/**
 * Extrage cypress_id din titlul testului
 * Format standard: "TC-0001: Test description" sau "[TC-0001] Test description"
 */
function extractCypressId(title) {
  const match = title.match(/^(?:\[)?(TC-\d{4})(?:\])?[\s\-:]/i);
  if (match) {
    return match[1].toUpperCase();
  }
  return null;
}

/**
 * Mapează starea testului Cypress la statusul Magi
 */
function mapStatus(state) {
  switch (state) {
    case 'passed':
      return 'passed';
    case 'failed':
      return 'failed';
    case 'pending':
    case 'skipped':
      return 'skipped';
    default:
      return 'untested';
  }
}

/**
 * Procesează rezultatele testelor și le pregătește pentru API
 */
function processResults(runResults) {
  const results = [];

  if (!runResults || !runResults.runs) {
    return results;
  }

  for (const run of runResults.runs) {
    if (!run.tests) continue;

    for (const test of run.tests) {
      const testTitle = test.title[test.title.length - 1];
      const cypressId = extractCypressId(testTitle);

      if (!cypressId) {
        console.log(`[Magi] Skipping test without ID: ${testTitle}`);
        continue;
      }

      const result = {
        cypress_id: cypressId,
        title: testTitle,
        status: mapStatus(test.state),
        duration_ms: test.duration || 0,
        error_message: null
      };

      if (test.state === 'failed' && test.displayError) {
        result.error_message = test.displayError;
      }

      results.push(result);
    }
  }

  return results;
}

/**
 * Trimite rezultatele către API-ul Magi
 */
async function sendToMagi(results, config) {
  const apiUrl = config.env.MAGI_API_URL || process.env.MAGI_API_URL;
  const apiToken = config.env.MAGI_API_TOKEN || process.env.MAGI_API_TOKEN;
  const testRunId = config.env.MAGI_TEST_RUN_ID || process.env.MAGI_TEST_RUN_ID;
  const projectId = config.env.MAGI_PROJECT_ID || process.env.MAGI_PROJECT_ID;
  const runName = config.env.MAGI_RUN_NAME || process.env.MAGI_RUN_NAME;
  const autoCreate = config.env.MAGI_AUTO_CREATE || process.env.MAGI_AUTO_CREATE;

  if (!apiUrl || !apiToken) {
    console.error('[Magi] Missing configuration. Required: MAGI_API_URL, MAGI_API_TOKEN');
    return null;
  }

  if (!testRunId && !projectId) {
    console.error('[Magi] Missing configuration. Required: MAGI_TEST_RUN_ID or MAGI_PROJECT_ID');
    return null;
  }

  if (results.length === 0) {
    console.log('[Magi] No test results with cypress_id to send.');
    return null;
  }

  // Determine API endpoint based on config
  let apiPath;
  if (projectId) {
    apiPath = `/api/v1/projects/${projectId}/cypress_results`;
    console.log(`[Magi] Using project mode (Project ID: ${projectId})`);
  } else {
    apiPath = `/api/v1/test_runs/${testRunId}/cypress_results`;
    console.log(`[Magi] Using test run mode (Test Run ID: ${testRunId})`);
  }

  const url = new URL(apiPath, apiUrl);
  const isHttps = url.protocol === 'https:';
  const httpModule = isHttps ? https : http;

  const requestBody = JSON.stringify({
    results,
    auto_create: autoCreate === true || autoCreate === 'true',
    run_name: runName || undefined
  });

  const options = {
    hostname: url.hostname,
    port: url.port || (isHttps ? 443 : 80),
    path: url.pathname,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiToken}`,
      'Content-Length': Buffer.byteLength(requestBody)
    }
  };

  return new Promise((resolve, reject) => {
    const req = httpModule.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);

          if (res.statusCode === 200) {
            console.log('[Magi] Results sent successfully!');

            if (response.test_run_name) {
              console.log(`[Magi] Test Run: ${response.test_run_name} (ID: ${response.test_run_id})`);
            }

            const s = response.summary;
            console.log(`[Magi] Summary: ${s.updated} updated, ${s.created || 0} created, ${s.not_found} not found`);

            if (response.summary.errors && response.summary.errors.length > 0) {
              console.log('[Magi] Errors:');
              response.summary.errors.forEach(err => console.log(`  - ${err}`));
            }
          } else {
            console.error(`[Magi] API Error (${res.statusCode}): ${response.error || data}`);
          }

          resolve(response);
        } catch (e) {
          console.error('[Magi] Failed to parse response:', data);
          reject(e);
        }
      });
    });

    req.on('error', (error) => {
      console.error('[Magi] Request failed:', error.message);
      reject(error);
    });

    req.write(requestBody);
    req.end();
  });
}

/**
 * Plugin principal pentru Cypress
 */
function magiReporter(on, config) {
  on('after:run', async (results) => {
    console.log('[Magi] Processing test results...');

    const processedResults = processResults(results);
    console.log(`[Magi] Found ${processedResults.length} tests with cypress_id`);

    if (processedResults.length > 0) {
      try {
        await sendToMagi(processedResults, config);
      } catch (error) {
        console.error('[Magi] Failed to send results:', error.message);
      }
    }
  });
}

module.exports = magiReporter;
module.exports.extractCypressId = extractCypressId;
module.exports.processResults = processResults;
