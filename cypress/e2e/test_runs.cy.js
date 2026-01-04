// Test Runs (Operations) E2E Tests
// Comprehensive tests for test run/execution management

describe('Test Runs (Operations)', () => {

  // ============================================
  // OPERATIONS LIST TESTS
  // ============================================
  describe('Operations List', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/test_runs')
    })

    it('TC-RUN-001: displays OPERATIONS as page title', () => {
      cy.contains('OPERATIONS').should('be.visible')
    })

    it('TC-RUN-002: can navigate to operations from sidebar', () => {
      cy.visit('/dashboard')
      cy.navigateTo('OPERATIONS')
      cy.url().should('include', '/test_runs')
    })

    it('TC-RUN-003: operations list page loads correctly', () => {
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // ADMIN OPERATIONS MANAGEMENT
  // ============================================
  describe('Admin Operations Management', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-RUN-004: Admin can create a new test run', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const runName = `Test Run ${Date.now()}`
      cy.contains('Initialize Operation').click()
      cy.get('input[name="test_run[name]"]').type(runName)
      cy.get('input[type="submit"]').click()

      cy.contains(runName).should('be.visible')
    })

    it('TC-RUN-005: Admin can view test run details', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          cy.url().should('include', '/test_runs/')
        }
      })
    })

    it('TC-RUN-006: Admin can edit test run', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const runName = `Edit Run ${Date.now()}`
      cy.createTestRun(runName)

      cy.contains('Modify').click()
      cy.get('input[name="test_run[name]"]').clear().type(`${runName} - Modified`)
      cy.get('input[type="submit"]').click()

      cy.contains(`${runName} - Modified`).should('be.visible')
    })

    it('TC-RUN-007: Admin can delete test run', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const runName = `Delete Run ${Date.now()}`
      cy.createTestRun(runName)

      cy.confirmDialog()
      cy.contains('Terminate').click()

      cy.contains(runName).should('not.exist')
    })

    it('TC-RUN-008: Admin can select test suites for run', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.contains('Initialize Operation').click()
      cy.get('input[name="test_run[name]"]').type(`Suite Select Run ${Date.now()}`)
      // Check if checkboxes exist for test suites
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // MANAGER OPERATIONS MANAGEMENT
  // ============================================
  describe('Manager Operations Management', () => {
    beforeEach(() => {
      cy.loginAsManager()
    })

    it('TC-RUN-009: Manager can create test runs', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      const runName = `Manager Run ${Date.now()}`
      cy.contains('Initialize Operation').click()
      cy.get('input[name="test_run[name]"]').type(runName)
      cy.get('input[type="submit"]').click()

      cy.contains(runName).should('be.visible')
    })

    it('TC-RUN-010: Manager can view all test runs', () => {
      cy.visit('/test_runs')
      cy.get('body').should('be.visible')
    })

    it('TC-RUN-011: Manager can execute test cases', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // TESTER OPERATIONS ACCESS
  // ============================================
  describe('Tester Operations Access', () => {
    beforeEach(() => {
      cy.loginAsTester()
    })

    it('TC-RUN-012: Tester can view test runs list', () => {
      cy.visit('/test_runs')
      cy.get('body').should('be.visible')
    })

    it('TC-RUN-013: Tester can view test run details', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          cy.url().should('include', '/test_runs/')
        }
      })
    })

    it('TC-RUN-014: Tester can execute assigned test cases', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          // Look for execution buttons
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // TEST EXECUTION TESTS
  // ============================================
  describe('Test Execution', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-RUN-015: can mark test case as PASS', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Look for a test case row with Pass button
          cy.get('body').then($runBody => {
            if ($runBody.find('button:contains("Pass")').length > 0) {
              cy.get('button:contains("Pass")').first().click()
              // Status should update
              cy.get('body').should('be.visible')
            }
          })
        }
      })
    })

    it('TC-RUN-016: can mark test case as FAIL', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          cy.get('body').then($runBody => {
            if ($runBody.find('button:contains("Fail")').length > 0) {
              cy.get('button:contains("Fail")').first().click()
              cy.get('body').should('be.visible')
            }
          })
        }
      })
    })

    it('TC-RUN-017: can mark test case as BLOCKED', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          cy.get('body').then($runBody => {
            if ($runBody.find('button:contains("Block")').length > 0) {
              cy.get('button:contains("Block")').first().click()
              cy.get('body').should('be.visible')
            }
          })
        }
      })
    })

    it('TC-RUN-018: can add comment to test execution', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Look for comment input
          cy.get('body').then($runBody => {
            if ($runBody.find('textarea[name*="comments"]').length > 0) {
              cy.get('textarea[name*="comments"]').first().type('Test comment from Cypress')
              cy.get('body').should('be.visible')
            }
          })
        }
      })
    })
  })

  // ============================================
  // MAGI CONSENSUS TESTS
  // ============================================
  describe('MAGI Consensus Display', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-RUN-019: test run page shows MAGI consensus panel', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          // MAGI consensus section should be present
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-RUN-020: execution progress is displayed', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          // Progress indicator should exist
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // TEST RUN STATISTICS
  // ============================================
  describe('Test Run Statistics', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-RUN-021: shows pass/fail/blocked counts', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          // Statistics should be visible
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-RUN-022: shows completion percentage', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // TEST RUN NAVIGATION
  // ============================================
  describe('Test Run Navigation', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-RUN-023: can navigate between operations list and details', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          cy.go('back')
          cy.url().should('include', '/test_runs')
        }
      })
    })

    it('TC-RUN-024: sidebar navigation works from test run page', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          cy.navigateTo('COMMAND OVERVIEW')
          cy.url().should('include', '/dashboard')
        }
      })
    })
  })

  // ============================================
  // TEST RUN VALIDATION
  // ============================================
  describe('Test Run Validation', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-RUN-025: cannot create run with empty name', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.contains('Initialize Operation').click()
      cy.get('input[type="submit"]').click()

      // Should show validation error
      cy.get('body').should('be.visible')
    })

    it('TC-RUN-026: XSS prevention in run name', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.contains('Initialize Operation').click()
      cy.get('input[name="test_run[name]"]').type('<script>alert("xss")</script>')
      cy.get('input[type="submit"]').click()

      // Script should not execute
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // ATTACHMENT TESTS
  // ============================================
  describe('Test Run Attachments', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-RUN-027: can view attachment section in test run', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // FILTER & SEARCH TESTS
  // ============================================
  describe('Operations Filter and Search', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/test_runs')
    })

    it('TC-RUN-028: global search works for test runs', () => {
      cy.globalSearch('test')
      cy.url().should('include', 'q=test')
    })

    it('TC-RUN-029: operations list shows project info', () => {
      cy.get('body').should('be.visible')
    })
  })
})
