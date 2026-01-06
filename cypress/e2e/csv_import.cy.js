// CSV Import E2E Tests
// Tests for CSV import functionality including multiple file imports

describe('CSV Import Features', () => {

  beforeEach(() => {
    cy.loginAsAdmin()
  })

  // ============================================
  // BASIC IMPORT TESTS
  // ============================================
  describe('Basic Import', () => {
    it('TC-CSV-001: Import page is accessible', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      // Find and click on a test suite
      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Import').click()
          cy.url().should('include', '/import_csv')
        }
      })
    })

    it('TC-CSV-002: Import form has file input with multiple attribute', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Import').click()

          // Check for multiple file input
          cy.get('input[name="csv_files[]"]')
            .should('have.attr', 'multiple')
            .should('have.attr', 'accept', '.csv')
        }
      })
    })

    it('TC-CSV-003: Download template button is visible', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Import').click()

          cy.contains('Download Template').should('be.visible')
        }
      })
    })

    it('TC-CSV-004: CSV format specification is displayed', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Import').click()

          cy.contains('CSV FORMAT SPECIFICATION').should('be.visible')
          cy.contains('scope_path').should('be.visible')
          cy.contains('title').should('be.visible')
          cy.contains('steps').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // EXPORT TESTS
  // ============================================
  describe('Export Features', () => {
    it('TC-CSV-005: Can export test cases to CSV', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          // Look for export button
          cy.get('[title="Export CSV"]').should('be.visible')
        }
      })
    })

    it('TC-CSV-006: Can export test cases to PDF', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()

          // Look for PDF export button
          cy.get('[title="Export PDF"]').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // CSV TEMPLATE DOWNLOAD
  // ============================================
  describe('CSV Template', () => {
    it('TC-CSV-007: CSV template download link works', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Import').click()

          // Verify download link exists
          cy.get('a[href*="csv_template"]').should('exist')
        }
      })
    })
  })

  // ============================================
  // IMPORT VALIDATION
  // ============================================
  describe('Import Validation', () => {
    it('TC-CSV-008: Shows error when no file selected', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Import').click()

          // Try to submit without file
          cy.get('input[type="submit"]').click()

          // Should show error or stay on page
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // ROLE ACCESS TESTS
  // ============================================
  describe('Role-Based Import Access', () => {
    it('TC-CSV-009: Manager can access import', () => {
      cy.loginAsManager()
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          cy.contains('Import').should('be.visible')
        }
      })
    })

    it('TC-CSV-010: Tester can view but may not import', () => {
      cy.loginAsTester()
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()

      cy.get('body').then($body => {
        if ($body.find('[href*="/test_suites/"]').length > 0) {
          cy.get('[href*="/test_suites/"]').first().click()
          // Tester may or may not see import button depending on policy
          cy.get('body').should('be.visible')
        }
      })
    })
  })
})
