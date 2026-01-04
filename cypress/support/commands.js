// Custom Cypress Commands for MAGI QA System Regression Testing

// ============================================
// AUTHENTICATION COMMANDS
// ============================================

// Login via UI
Cypress.Commands.add('login', (email, password) => {
  cy.session([email, password], () => {
    cy.visit('/users/sign_in')
    cy.get('input[name="user[email]"]').type(email)
    cy.get('input[name="user[password]"]').type(password)
    cy.get('input[type="submit"]').click()
    cy.url().should('not.include', '/sign_in')
  })
})

// Login as Admin
Cypress.Commands.add('loginAsAdmin', () => {
  cy.login(Cypress.env('adminEmail'), Cypress.env('adminPassword'))
})

// Login as Manager
Cypress.Commands.add('loginAsManager', () => {
  cy.login(Cypress.env('managerEmail'), Cypress.env('managerPassword'))
})

// Login as Tester
Cypress.Commands.add('loginAsTester', () => {
  cy.login(Cypress.env('testerEmail'), Cypress.env('testerPassword'))
})

// Login as User (alias for Tester - for backward compatibility)
Cypress.Commands.add('loginAsUser', () => {
  cy.login(Cypress.env('testerEmail'), Cypress.env('testerPassword'))
})

// Logout
Cypress.Commands.add('logout', () => {
  cy.get('aside').contains('Disconnect').click({ force: true })
  cy.url().should('include', '/sign_in')
})

// ============================================
// NAVIGATION COMMANDS
// ============================================

// Navigate to sidebar item
Cypress.Commands.add('navigateTo', (menuItem) => {
  cy.get('aside').contains(menuItem, { matchCase: false }).click()
})

// Navigate to dashboard
Cypress.Commands.add('goToDashboard', () => {
  cy.navigateTo('Command Overview')
})

// Navigate to projects
Cypress.Commands.add('goToProjects', () => {
  cy.navigateTo('Missions')
})

// Navigate to test runs
Cypress.Commands.add('goToTestRuns', () => {
  cy.navigateTo('Operations')
})

// Navigate to system config
Cypress.Commands.add('goToSystemConfig', () => {
  cy.navigateTo('System Config')
})

// Global search
Cypress.Commands.add('globalSearch', (query) => {
  cy.get('header input[name="q"]').clear().type(query)
  cy.get('header form').submit()
})

// ============================================
// PROJECT COMMANDS
// ============================================

// Create a new project
Cypress.Commands.add('createProject', (name, description = 'Test project created by Cypress') => {
  cy.goToProjects()
  cy.contains('Initialize Mission').click()
  cy.get('input[name="project[name]"]').type(name)
  cy.get('textarea[name="project[description]"]').type(description)
  cy.get('input[type="submit"]').click()
  cy.contains(name).should('be.visible')
})

// Open a project by name
Cypress.Commands.add('openProject', (projectName) => {
  cy.goToProjects()
  cy.contains('.nerv-panel', projectName).click()
})

// ============================================
// TEST SUITE COMMANDS
// ============================================

// Create a test suite within current project
Cypress.Commands.add('createTestSuite', (name, description = 'Test suite created by Cypress') => {
  cy.contains('Initialize Bank').click()
  cy.get('input[name="test_suite[name]"]').type(name)
  cy.get('textarea[name="test_suite[description]"]').type(description)
  cy.get('input[type="submit"]').click()
  cy.contains(name).should('be.visible')
})

// Open a test suite by name
Cypress.Commands.add('openTestSuite', (suiteName) => {
  cy.contains('.nerv-panel', suiteName).within(() => {
    cy.get('a').first().click()
  })
})

// ============================================
// TEST CASE COMMANDS
// ============================================

// Create a test case within current test suite
Cypress.Commands.add('createTestCase', (title, options = {}) => {
  cy.contains('Initialize Protocol').click()
  cy.get('input[name="test_case[title]"]').type(title)

  if (options.preconditions) {
    cy.get('textarea[name="test_case[preconditions]"]').type(options.preconditions)
  }
  if (options.steps) {
    cy.get('textarea[name="test_case[steps]"]').type(options.steps)
  }
  if (options.expectedResult) {
    cy.get('textarea[name="test_case[expected_result]"]').type(options.expectedResult)
  }
  if (options.cypressId) {
    cy.get('input[name="test_case[cypress_id]"]').type(options.cypressId)
  }

  cy.get('input[type="submit"]').click()
  cy.contains(title).should('be.visible')
})

// ============================================
// TEST RUN COMMANDS
// ============================================

// Create a test run within current project
Cypress.Commands.add('createTestRun', (name, testSuites = []) => {
  cy.contains('Initialize Operation').click()
  cy.get('input[name="test_run[name]"]').type(name)

  // Select test suites if provided
  testSuites.forEach(suite => {
    cy.contains('label', suite).click()
  })

  cy.get('input[type="submit"]').click()
  cy.contains(name).should('be.visible')
})

// Execute a test case with status
Cypress.Commands.add('executeTestCase', (testCaseTitle, status) => {
  cy.contains('tr', testCaseTitle).within(() => {
    switch(status.toLowerCase()) {
      case 'pass':
      case 'passed':
        cy.get('button').contains('Pass', { matchCase: false }).click()
        break
      case 'fail':
      case 'failed':
        cy.get('button').contains('Fail', { matchCase: false }).click()
        break
      case 'block':
      case 'blocked':
        cy.get('button').contains('Block', { matchCase: false }).click()
        break
    }
  })
})

// ============================================
// THEME COMMANDS
// ============================================

// Toggle theme
Cypress.Commands.add('toggleTheme', () => {
  cy.get('[data-controller="theme-toggle"] button').click()
})

// Verify NERV theme
Cypress.Commands.add('verifyNervTheme', () => {
  cy.get('body').should('have.class', 'theme-nerv')
})

// Verify Light theme
Cypress.Commands.add('verifyLightTheme', () => {
  cy.get('body').should('have.class', 'theme-light')
})

// ============================================
// NOTIFICATION COMMANDS
// ============================================

// Open notifications dropdown
Cypress.Commands.add('openNotifications', () => {
  cy.get('[data-controller="notifications"] button').first().click()
})

// Get notification count
Cypress.Commands.add('getNotificationCount', () => {
  return cy.get('[data-notifications-target="badge"]').invoke('text')
})

// ============================================
// API COMMANDS
// ============================================

// API login and get token
Cypress.Commands.add('apiCreateToken', (email, password) => {
  // Login first to create a token via UI
  cy.login(email, password)
  cy.visit('/system_config?section=api_tokens')
  cy.get('input[name="api_token[name]"]').type('Cypress Test Token')
  cy.get('input[type="submit"]').click()
  // Get the token from flash message
  return cy.get('.bg-terminal-cyan').invoke('text')
})

// API request with token
Cypress.Commands.add('apiRequest', (method, url, token, body = null) => {
  const options = {
    method: method,
    url: url,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    failOnStatusCode: false
  }

  if (body) {
    options.body = body
  }

  return cy.request(options)
})

// ============================================
// UTILITY COMMANDS
// ============================================

// Clear Turbo cache
Cypress.Commands.add('clearTurboCache', () => {
  cy.window().then((win) => {
    if (win.Turbo) {
      win.Turbo.cache.clear()
    }
  })
})

// Wait for page load
Cypress.Commands.add('waitForPageLoad', () => {
  cy.get('body').should('be.visible')
  cy.wait(500) // Small wait for Turbo/Stimulus to initialize
})

// Check for flash message
Cypress.Commands.add('checkFlashMessage', (type, text) => {
  const selector = type === 'success' ? '.alert-success' : '.alert-error'
  cy.get(selector).should('contain', text)
})

// Confirm dialog
Cypress.Commands.add('confirmDialog', () => {
  cy.on('window:confirm', () => true)
})

// Deny dialog
Cypress.Commands.add('denyDialog', () => {
  cy.on('window:confirm', () => false)
})

// Take screenshot with name
Cypress.Commands.add('takeScreenshot', (name) => {
  cy.screenshot(name, { capture: 'viewport' })
})
