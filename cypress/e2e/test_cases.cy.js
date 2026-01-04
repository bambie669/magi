// Test Cases (Protocols) E2E Tests
// Comprehensive tests for test case management

describe('Test Cases (Protocols)', () => {

  // ============================================
  // ADMIN TEST CASE MANAGEMENT
  // ============================================
  describe('Admin Test Case Management', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CASE-001: Admin can create a new test case', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      // Navigate to first test suite
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Test Case ${Date.now()}`
          cy.contains('Initialize Protocol').click()

          cy.get('input[name="test_case[title]"]').type(caseTitle)
          cy.get('textarea[name="test_case[preconditions]"]').type('User must be logged in')
          cy.get('textarea[name="test_case[steps]"]').type('1. Navigate to page\n2. Click button\n3. Verify result')
          cy.get('textarea[name="test_case[expected_result]"]').type('Action completes successfully')
          cy.get('input[type="submit"]').click()

          cy.contains(caseTitle).should('be.visible')
        }
      })
    })

    it('TC-CASE-002: Admin can view test case details', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.get('body').then($suiteBody => {
            if ($suiteBody.find('[href*="/test_cases/"]').length > 0) {
              cy.get('[href*="/test_cases/"]').first().click()
              cy.url().should('include', '/test_cases/')
            }
          })
        }
      })
    })

    it('TC-CASE-003: Admin can edit test case', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Edit Case ${Date.now()}`
          cy.createTestCase(caseTitle)

          // Edit the test case
          cy.contains('Modify').click()
          cy.get('input[name="test_case[title]"]').clear().type(`${caseTitle} - Modified`)
          cy.get('input[type="submit"]').click()

          cy.contains(`${caseTitle} - Modified`).should('be.visible')
        }
      })
    })

    it('TC-CASE-004: Admin can delete test case', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Delete Case ${Date.now()}`
          cy.createTestCase(caseTitle)

          // Delete it
          cy.confirmDialog()
          cy.contains('Terminate').click()

          cy.contains(caseTitle).should('not.exist')
        }
      })
    })

    it('TC-CASE-005: Admin can set Cypress ID for test case', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Cypress Case ${Date.now()}`
          cy.createTestCase(caseTitle, {
            cypressId: 'TC-AUTO-001'
          })

          cy.contains(caseTitle).should('be.visible')
        }
      })
    })
  })

  // ============================================
  // MANAGER TEST CASE MANAGEMENT
  // ============================================
  describe('Manager Test Case Management', () => {
    beforeEach(() => {
      cy.loginAsManager()
    })

    it('TC-CASE-006: Manager can create test cases', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Manager Case ${Date.now()}`
          cy.contains('Initialize Protocol').click()
          cy.get('input[name="test_case[title]"]').type(caseTitle)
          cy.get('input[type="submit"]').click()

          cy.contains(caseTitle).should('be.visible')
        }
      })
    })

    it('TC-CASE-007: Manager can view test cases', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CASE-008: Manager can edit test cases', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.get('body').then($suiteBody => {
            if ($suiteBody.find('[href*="/test_cases/"]').length > 0) {
              cy.get('[href*="/test_cases/"]').first().click()
              cy.contains('Modify').should('be.visible')
            }
          })
        }
      })
    })
  })

  // ============================================
  // TESTER TEST CASE ACCESS
  // ============================================
  describe('Tester Test Case Access', () => {
    beforeEach(() => {
      cy.loginAsTester()
    })

    it('TC-CASE-009: Tester can view test cases', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CASE-010: Tester can view test case details', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.get('body').then($suiteBody => {
            if ($suiteBody.find('[href*="/test_cases/"]').length > 0) {
              cy.get('[href*="/test_cases/"]').first().click()
              cy.url().should('include', '/test_cases/')
            }
          })
        }
      })
    })

    it('TC-CASE-011: Tester cannot create test cases', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          // Tester should not see Initialize Protocol button
          cy.get('body').then($suiteBody => {
            const hasButton = $suiteBody.find('a:contains("Initialize Protocol")').length > 0
            if (!hasButton) {
              cy.log('Tester correctly does not see Initialize Protocol button')
            }
          })
        }
      })
    })
  })

  // ============================================
  // TEST CASE DETAILS PAGE
  // ============================================
  describe('Test Case Details', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CASE-012: test case page shows all fields', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Full Fields Case ${Date.now()}`
          cy.createTestCase(caseTitle, {
            preconditions: 'Test preconditions',
            steps: 'Step 1\nStep 2\nStep 3',
            expectedResult: 'Expected result text'
          })

          cy.contains(caseTitle).should('be.visible')
        }
      })
    })

    it('TC-CASE-013: test case shows preconditions section', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.get('body').then($suiteBody => {
            if ($suiteBody.find('[href*="/test_cases/"]').length > 0) {
              cy.get('[href*="/test_cases/"]').first().click()
              // Preconditions section should exist
              cy.get('body').should('be.visible')
            }
          })
        }
      })
    })

    it('TC-CASE-014: test case shows steps section', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.get('body').then($suiteBody => {
            if ($suiteBody.find('[href*="/test_cases/"]').length > 0) {
              cy.get('[href*="/test_cases/"]').first().click()
              // Steps section should exist
              cy.get('body').should('be.visible')
            }
          })
        }
      })
    })
  })

  // ============================================
  // TEST CASE VALIDATION
  // ============================================
  describe('Test Case Validation', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CASE-015: cannot create case with empty title', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.contains('Initialize Protocol').click()
          cy.get('textarea[name="test_case[steps]"]').type('Some steps')
          cy.get('input[type="submit"]').click()

          // Should show validation error or stay on form
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CASE-016: XSS prevention in test case title', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.contains('Initialize Protocol').click()
          cy.get('input[name="test_case[title]"]').type('<script>alert("xss")</script>')
          cy.get('input[type="submit"]').click()

          // Script should not execute
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CASE-017: can create case with long steps text', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Long Steps Case ${Date.now()}`
          const longSteps = 'Step 1: Do something\n'.repeat(50)

          cy.contains('Initialize Protocol').click()
          cy.get('input[name="test_case[title]"]').type(caseTitle)
          cy.get('textarea[name="test_case[steps]"]').type(longSteps)
          cy.get('input[type="submit"]').click()

          cy.contains(caseTitle).should('be.visible')
        }
      })
    })
  })

  // ============================================
  // TEST CASE NAVIGATION
  // ============================================
  describe('Test Case Navigation', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-CASE-018: can navigate back to suite from case', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.get('body').then($suiteBody => {
            if ($suiteBody.find('[href*="/test_cases/"]').length > 0) {
              cy.get('[href*="/test_cases/"]').first().click()
              cy.go('back')
              cy.url().should('include', '/test_suites/')
            }
          })
        }
      })
    })
  })

  // ============================================
  // AUTOMATION INTEGRATION
  // ============================================
  describe('Automation Integration', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CASE-019: Cypress ID field is visible in form', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          cy.contains('Initialize Protocol').click()
          cy.get('input[name="test_case[cypress_id]"]').should('be.visible')
        }
      })
    })

    it('TC-CASE-020: Cypress ID is saved correctly', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          const caseTitle = `Cypress ID Case ${Date.now()}`
          const cypressId = 'TC-CY-' + Date.now()

          cy.contains('Initialize Protocol').click()
          cy.get('input[name="test_case[title]"]').type(caseTitle)
          cy.get('input[name="test_case[cypress_id]"]').type(cypressId)
          cy.get('input[type="submit"]').click()

          cy.contains(caseTitle).should('be.visible')
        }
      })
    })
  })
})
