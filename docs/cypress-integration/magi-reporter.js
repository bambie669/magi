/**
 * Magi QA Reporter for Cypress
 *
 * Acest plugin trimite rezultatele testelor Cypress către API-ul Magi QA.
 *
 * Configurare în cypress.config.js:
 *
 * const { defineConfig } = require('cypress');
 * const magiReporter = require('./magi-reporter');
 *
 * module.exports = defineConfig({
 *   e2e: {
 *     setupNodeEvents(on, config) {
 *       magiReporter(on, config);
 *       return config;
 *     }
 *   },
 *   env: {
 *     MAGI_API_URL: 'http://localhost:2507',
 *     MAGI_API_TOKEN: 'your_token_here',
 *     MAGI_TEST_RUN_ID: '123'
 *   }
 * });
 */

const https = require('https');
const http = require('http');

/**
 * Extrage cypress_id din titlul testului
 * Convenție: "TC-001: Test description" sau "[TC-001] Test description"
 */
function extractCypressId(title) {
  // Match patterns like "TC-001:", "TC-001 -", "[TC-001]", "MAGI-123:", "ID: 123", "TC123"
  const patterns = [
    /^(TC-?\d+)[\s:|-]/i,      // TC-001 or TC001 followed by separator
    /^\[(TC-?\d+)\]/i,          // [TC-001] or [TC001]
    /^(MAGI-\d+)[\s:|-]/i,      // MAGI-001 followed by separator
    /^\[(MAGI-\d+)\]/i,         // [MAGI-001]
    /^ID:\s*(\d+)[\s-]/i,       // ID: 123 or ID:123 followed by space or hyphen
  ];

  for (const pattern of patterns) {
    const match = title.match(pattern);
    if (match) {
      return match[1].toUpperCase();
    }
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
      // Construiește titlul complet din titlurile părinților
      const fullTitle = test.title.join(' > ');
      const testTitle = test.title[test.title.length - 1];

      const cypressId = extractCypressId(testTitle);

      if (!cypressId) {
        console.log(`[Magi] Skipping test without ID: ${testTitle}`);
        continue;
      }

      const result = {
        cypress_id: cypressId,
        status: mapStatus(test.state),
        duration_ms: test.duration || 0,
        error_message: null
      };

      // Adaugă mesajul de eroare dacă testul a eșuat
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

  if (!apiUrl || !apiToken || !testRunId) {
    console.error('[Magi] Missing configuration. Required: MAGI_API_URL, MAGI_API_TOKEN, MAGI_TEST_RUN_ID');
    return null;
  }

  if (results.length === 0) {
    console.log('[Magi] No test results with cypress_id to send.');
    return null;
  }

  const url = new URL(`/api/v1/test_runs/${testRunId}/cypress_results`, apiUrl);
  const isHttps = url.protocol === 'https:';
  const httpModule = isHttps ? https : http;

  const requestBody = JSON.stringify({ results });

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
            console.log(`[Magi] Summary: ${response.summary.updated} updated, ${response.summary.not_found} not found`);

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
