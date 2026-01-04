const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:2507',
    supportFile: 'cypress/support/e2e.js',
    specPattern: 'cypress/e2e/**/*.cy.js',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false,
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 30000,
    retries: {
      runMode: 2,
      openMode: 0
    }
  },
  env: {
    // Admin user
    adminEmail: 'admin@example.com',
    adminPassword: 'password',
    // Manager user
    managerEmail: 'manager@example.com',
    managerPassword: 'password',
    // Tester user
    testerEmail: 'tester@example.com',
    testerPassword: 'password'
  }
})
