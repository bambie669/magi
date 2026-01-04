const { defineConfig } = require('cypress');
const magiReporter = require('./magi-reporter');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',

    setupNodeEvents(on, config) {
      // Înregistrează Magi reporter
      magiReporter(on, config);

      return config;
    },

    // Specificații de test
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
  },

  // Variabile de mediu pentru Magi
  // Acestea pot fi suprascrise din linia de comandă sau din cypress.env.json
  env: {
    // URL-ul API-ului Magi QA
    MAGI_API_URL: 'http://localhost:2507',

    // Token-ul de autentificare (generează din rails console)
    MAGI_API_TOKEN: 'your_api_token_here',

    // ID-ul TestRun-ului în care se salvează rezultatele
    // Poate fi setat dinamic în CI/CD
    MAGI_TEST_RUN_ID: '1'
  }
});
