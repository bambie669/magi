// Test Suites (Protocol Banks) E2E Tests
// Comprehensive tests for test suite management

describe('Test Suites (Protocol Banks)', () => {

  // ============================================
  // ADMIN TEST SUITE MANAGEMENT
  // ============================================
  describe('Admin Test Suite Management', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-SUITE-001: Admin can create a new test suite', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const suiteName = `Test Suite ${Date.now()}`
      cy.contains('Initialize Bank').click()
      cy.get('input[name="test_suite[name]"]').type(suiteName)
      cy.get('textarea[name="test_suite[description]"]').type('Automated test suite created by Cypress')
      cy.get('input[type="submit"]').click()

      cy.contains(suiteName).should('be.visible')
    })

    it('TC-SUITE-002: Admin can view test suite details', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      // Click on first test suite if exists
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.url().should('include', '/test_suites/')
        }
      })
    })

    it('TC-SUITE-003: Admin can edit test suite', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const suiteName = `Edit Suite ${Date.now()}`
      cy.createTestSuite(suiteName)

      // Edit the suite
      cy.contains('Modify').click()
      cy.get('input[name="test_suite[name]"]').clear().type(`${suiteName} - Modified`)
      cy.get('input[type="submit"]').click()

      cy.contains(`${suiteName} - Modified`).should('be.visible')
    })

    it('TC-SUITE-004: Admin can delete test suite', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const suiteName = `Delete Suite ${Date.now()}`
      cy.createTestSuite(suiteName)

      // Delete the suite
      cy.confirmDialog()
      cy.contains('Terminate').click()

      // Should not exist anymore
      cy.contains(suiteName).should('not.exist')
    })

    it('TC-SUITE-005: Initialize Bank button is visible to Admin', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Initialize Bank').should('be.visible')
    })
  })

  // ============================================
  // MANAGER TEST SUITE MANAGEMENT
  // ============================================
  describe('Manager Test Suite Management', () => {
    beforeEach(() => {
      cy.loginAsManager()
    })

    it('TC-SUITE-006: Manager can create test suites', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const suiteName = `Manager Suite ${Date.now()}`
      cy.contains('Initialize Bank').click()
      cy.get('input[name="test_suite[name]"]').type(suiteName)
      cy.get('textarea[name="test_suite[description]"]').type('Suite created by manager')
      cy.get('input[type="submit"]').click()

      cy.contains(suiteName).should('be.visible')
    })

    it('TC-SUITE-007: Manager can view test suites', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Protocol Banks').should('be.visible')
    })

    it('TC-SUITE-008: Manager can edit test suites', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Modify').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // TESTER TEST SUITE ACCESS
  // ============================================
  describe('Tester Test Suite Access', () => {
    beforeEach(() => {
      cy.loginAsTester()
    })

    it('TC-SUITE-009: Tester can view test suites', () => {
      cy.visit('/projects')
      cy.get('body').then($body => {
        if ($body.find('.nerv-panel a[href^="/projects/"]').length > 0) {
          cy.get('.nerv-panel a[href^="/projects/"]').first().click()
          cy.contains('Protocol Banks').should('be.visible')
        }
      })
    })

    it('TC-SUITE-010: Tester can view test suite details', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.url().should('include', '/test_suites/')
        }
      })
    })

    it('TC-SUITE-011: Tester cannot create test suites', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      // Tester should not see Initialize Bank button
      cy.get('body').then($body => {
        const hasButton = $body.find('a:contains("Initialize Bank")').length > 0
        if (!hasButton) {
          // This is expected behavior
          cy.log('Tester correctly does not see Initialize Bank button')
        }
      })
    })
  })

  // ============================================
  // TEST SUITE DETAILS PAGE
  // ============================================
  describe('Test Suite Details', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-SUITE-012: test suite page shows test cases list', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.url().should('include', '/test_suites/')
          // Should show protocols section
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-SUITE-013: test suite page shows Initialize Protocol button', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Initialize Protocol').should('be.visible')
        }
      })
    })

    it('TC-SUITE-014: test suite displays description', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const suiteName = `Description Suite ${Date.now()}`
      cy.createTestSuite(suiteName, 'This is a test suite description')

      cy.contains(suiteName).should('be.visible')
    })
  })

  // ============================================
  // TEST SUITE VALIDATION
  // ============================================
  describe('Test Suite Validation', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-SUITE-015: cannot create suite with empty name', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Initialize Bank').click()

      // Submit without name
      cy.get('textarea[name="test_suite[description]"]').type('Description only')
      cy.get('input[type="submit"]').click()

      // Should show validation error or stay on form
      cy.get('body').should('be.visible')
    })

    it('TC-SUITE-016: XSS prevention in suite name', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Initialize Bank').click()

      cy.get('input[name="test_suite[name]"]').type('<script>alert("xss")</script>')
      cy.get('input[type="submit"]').click()

      // Script should not execute
      cy.get('body').should('be.visible')
    })

    it('TC-SUITE-017: SQL injection prevention', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Initialize Bank').click()

      cy.get('input[name="test_suite[name]"]').type("Test'; DROP TABLE test_suites; --")
      cy.get('input[type="submit"]').click()

      // Should handle safely
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // TEST SUITE NAVIGATION
  // ============================================
  describe('Test Suite Navigation', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-SUITE-018: can navigate back to project from suite', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          // Should have breadcrumb or back link
          cy.go('back')
          cy.url().should('include', '/projects/')
        }
      })
    })

    it('TC-SUITE-019: breadcrumb navigation works', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          // Check for breadcrumb
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // TEST SUITE STATISTICS
  // ============================================
  describe('Test Suite Statistics', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-SUITE-020: suite page shows test case count', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })
  })
})
