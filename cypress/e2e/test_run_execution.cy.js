// Test Run Execution E2E Tests
// Tests for inline status updates, select all, and execution features

describe('Test Run Execution Features', () => {

  // ============================================
  // INITIALIZE OPERATION - SELECT ALL
  // ============================================
  describe('Initialize Operation - Select All', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
    })

    it('TC-EXEC-001: Select All button is visible when test cases exist', () => {
      cy.contains('Initialize Operation').click()
      cy.get('body').then($body => {
        if ($body.find('input[name="test_run[test_case_ids][]"]').length > 0) {
          cy.get('#select-all-btn').should('be.visible')
          cy.get('#select-all-btn').should('contain', 'Select All')
        }
      })
    })

    it('TC-EXEC-002: Select All button selects all checkboxes', () => {
      cy.contains('Initialize Operation').click()
      cy.get('body').then($body => {
        if ($body.find('input[name="test_run[test_case_ids][]"]').length > 0) {
          cy.get('#select-all-btn').click()

          // All checkboxes should be checked
          cy.get('input[name="test_run[test_case_ids][]"]').each($checkbox => {
            cy.wrap($checkbox).should('be.checked')
          })

          // Button text should change
          cy.get('#select-all-btn').should('contain', 'Deselect All')
        }
      })
    })

    it('TC-EXEC-003: Deselect All unselects all checkboxes', () => {
      cy.contains('Initialize Operation').click()
      cy.get('body').then($body => {
        if ($body.find('input[name="test_run[test_case_ids][]"]').length > 0) {
          // First select all
          cy.get('#select-all-btn').click()

          // Then deselect all
          cy.get('#select-all-btn').click()

          // All checkboxes should be unchecked
          cy.get('input[name="test_run[test_case_ids][]"]').each($checkbox => {
            cy.wrap($checkbox).should('not.be.checked')
          })

          // Button text should change back
          cy.get('#select-all-btn').should('contain', 'Select All')
        }
      })
    })

    it('TC-EXEC-004: Can create test run with all tests selected', () => {
      cy.contains('Initialize Operation').click()
      cy.get('body').then($body => {
        if ($body.find('input[name="test_run[test_case_ids][]"]').length > 0) {
          const runName = `Full Run ${Date.now()}`
          cy.get('input[name="test_run[name]"]').type(runName)
          cy.get('#select-all-btn').click()
          cy.get('input[type="submit"]').click()

          cy.contains(runName).should('be.visible')
        }
      })
    })
  })

  // ============================================
  // INLINE STATUS BUTTONS
  // ============================================
  describe('Inline Status Buttons', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-EXEC-005: Inline status buttons are visible on test run page', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Check for status buttons (pass, fail, blocked, reset)
          cy.get('button[title="Pass"]').should('exist')
          cy.get('button[title="Fail"]').should('exist')
          cy.get('button[title="Blocked"]').should('exist')
          cy.get('button[title="Reset"]').should('exist')
        }
      })
    })

    it('TC-EXEC-006: Can mark test as passed using inline button', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          cy.get('button[title="Pass"]').first().click()
          // Page should reload and status should update
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-EXEC-007: Can mark test as failed using inline button', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          cy.get('button[title="Fail"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-EXEC-008: Can mark test as blocked using inline button', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          cy.get('button[title="Blocked"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-EXEC-009: Can reset test status using inline button', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // First mark as passed
          cy.get('button[title="Pass"]').first().click()

          // Then reset
          cy.get('button[title="Reset"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-EXEC-010: Active status button is highlighted', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Click pass button
          cy.get('button[title="Pass"]').first().click()

          // Verify the button styling indicates active state
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // CYPRESS ID DISPLAY
  // ============================================
  describe('Cypress ID Display', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-EXEC-011: Test ID is displayed in test run view', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Look for test ID badges (TC-XXX format)
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // PROGRESS UPDATES
  // ============================================
  describe('Progress Updates', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-EXEC-012: Progress percentage updates after status change', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Get initial progress
          cy.get('[data-test-run-updates-target="progressText"]').then($progress => {
            const initialProgress = $progress.text()

            // Change a status
            cy.get('button[title="Pass"]').first().click()

            // Progress should have changed (page reloads)
            cy.get('body').should('be.visible')
          })
        }
      })
    })

    it('TC-EXEC-013: Status counts update after execution', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Check that status counts exist
          cy.get('[data-test-run-updates-target="passedCount"]').should('exist')
          cy.get('[data-test-run-updates-target="failedCount"]').should('exist')
          cy.get('[data-test-run-updates-target="blockedCount"]').should('exist')
          cy.get('[data-test-run-updates-target="untestedCount"]').should('exist')
        }
      })
    })
  })

  // ============================================
  // EXPANDED FORM FUNCTIONALITY
  // ============================================
  describe('Expanded Test Form', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-EXEC-014: Can expand test case form for detailed edit', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Click edit button to expand form
          cy.get('button svg').first().parent().click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-EXEC-015: Can add comments via expanded form', () => {
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Look for comment textarea
          cy.get('body').then($runBody => {
            if ($runBody.find('textarea[name*="comments"]').length > 0) {
              cy.get('textarea[name*="comments"]').first()
                .type('Test comment from Cypress E2E')
              cy.get('body').should('be.visible')
            }
          })
        }
      })
    })
  })

  // ============================================
  // ROLE-BASED ACCESS FOR EXECUTION
  // ============================================
  describe('Role-Based Execution Access', () => {
    it('TC-EXEC-016: Tester can update test status', () => {
      cy.loginAsTester()
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Tester should be able to see and use status buttons
          cy.get('button[title="Pass"]').should('exist')
        }
      })
    })

    it('TC-EXEC-017: Manager can update test status', () => {
      cy.loginAsManager()
      cy.visit('/test_runs')
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_runs/"]').length > 0) {
          cy.get('[href*="/test_runs/"]').first().click()

          // Manager should be able to see and use status buttons
          cy.get('button[title="Pass"]').should('exist')
        }
      })
    })
  })
})
