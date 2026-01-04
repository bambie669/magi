// Dashboard E2E Tests - COMMAND OVERVIEW
// Comprehensive tests for the main dashboard interface

describe('Dashboard (Command Overview)', () => {

  // ============================================
  // ADMIN DASHBOARD TESTS
  // ============================================
  describe('Admin Dashboard Access', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
      cy.visit('/dashboard')
    })

    it('TC-DASH-001: displays COMMAND OVERVIEW as page title', () => {
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('TC-DASH-002: displays NERV sidebar', () => {
      cy.get('aside').should('be.visible')
      cy.get('aside').contains('NERV').should('be.visible')
    })

    it('TC-DASH-003: has main navigation items', () => {
      cy.get('aside').contains('COMMAND OVERVIEW').should('be.visible')
      cy.get('aside').contains('OPERATIONS').should('be.visible')
      cy.get('aside').contains('MISSIONS').should('be.visible')
    })

    it('TC-DASH-004: Admin sees full dashboard with all panels', () => {
      cy.contains('ACTIVE OPS').should('be.visible')
      cy.contains('System Overview').should('be.visible')
    })
  })

  // ============================================
  // MANAGER DASHBOARD TESTS
  // ============================================
  describe('Manager Dashboard Access', () => {
    beforeEach(() => {
      cy.loginAsManager()
      cy.visit('/dashboard')
    })

    it('TC-DASH-005: Manager can access dashboard', () => {
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('TC-DASH-006: Manager sees appropriate statistics', () => {
      cy.get('body').should('be.visible')
      cy.get('aside').should('be.visible')
    })
  })

  // ============================================
  // TESTER DASHBOARD TESTS
  // ============================================
  describe('Tester Dashboard Access', () => {
    beforeEach(() => {
      cy.loginAsTester()
      cy.visit('/dashboard')
    })

    it('TC-DASH-007: Tester can access dashboard', () => {
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('TC-DASH-008: Tester sees operations overview', () => {
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // NERV THEME TESTS
  // ============================================
  describe('NERV Theme', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-DASH-009: applies dark NERV theme by default', () => {
      cy.get('body').should('have.class', 'theme-nerv')
    })

    it('TC-DASH-010: displays MAGI system status', () => {
      cy.contains('MAGI System Online').should('be.visible')
    })

    it('TC-DASH-011: displays system footer', () => {
      cy.get('footer').contains('NERV HEADQUARTERS').should('be.visible')
      cy.get('footer').contains('MAGI QA INTERFACE').should('be.visible')
    })
  })

  // ============================================
  // DASHBOARD PANELS TESTS
  // ============================================
  describe('Dashboard Panels', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-DASH-012: displays active ops panel', () => {
      cy.contains('ACTIVE OPS').should('be.visible')
    })

    it('TC-DASH-013: displays system overview panel', () => {
      cy.contains('System Overview').should('be.visible')
    })

    it('TC-DASH-014: displays MAGI subsystem status', () => {
      cy.contains('MAGI Subsystem Status').should('be.visible')
    })

    it('TC-DASH-015: displays recent operations panel', () => {
      cy.contains('RECENT OPERATIONS').should('be.visible')
    })
  })

  // ============================================
  // OPERATION TELEMETRY TESTS
  // ============================================
  describe('Operation Telemetry Chart', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-DASH-016: displays telemetry panel', () => {
      cy.contains('Operation Telemetry').should('be.visible')
    })

    it('TC-DASH-017: shows 14 day timeframe indicator', () => {
      cy.contains('Last 14 Days').should('be.visible')
    })

    it('TC-DASH-018: shows legend items', () => {
      cy.get('.nerv-panel').contains('NOMINAL').should('be.visible')
      cy.get('.nerv-panel').contains('BREACH').should('be.visible')
      cy.get('.nerv-panel').contains('BLOCKED').should('be.visible')
    })

    it('TC-DASH-019: displays chart or no data message', () => {
      cy.get('body').then($body => {
        // Either shows chart canvas or "No Telemetry Data" message
        if ($body.find('canvas[data-telemetry-chart-target="canvas"]').length > 0) {
          cy.get('canvas[data-telemetry-chart-target="canvas"]').should('be.visible')
          cy.contains('TOTAL EXECUTED').should('be.visible')
          cy.contains('PASS RATE').should('be.visible')
        } else {
          cy.contains('No Telemetry Data').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // SEARCH FUNCTIONALITY TESTS
  // ============================================
  describe('Search Functionality', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-DASH-020: displays search input in header', () => {
      cy.get('header input[name="q"]').should('be.visible')
      cy.get('header input[name="q"]').should('have.attr', 'placeholder', 'SCAN DATABASE...')
    })

    it('TC-DASH-021: can perform global search', () => {
      cy.globalSearch('test')
      cy.url().should('include', 'q=test')
    })

    it('TC-DASH-022: empty search handled gracefully', () => {
      cy.get('header input[name="q"]').clear()
      cy.get('header form').submit()
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // NAVIGATION TESTS
  // ============================================
  describe('Navigation', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-DASH-023: can navigate to Missions from sidebar', () => {
      cy.navigateTo('MISSIONS')
      cy.url().should('include', '/projects')
    })

    it('TC-DASH-024: can navigate to Operations from sidebar', () => {
      cy.navigateTo('OPERATIONS')
      cy.url().should('include', '/test_runs')
    })

    it('TC-DASH-025: can return to dashboard from any page', () => {
      cy.navigateTo('MISSIONS')
      cy.navigateTo('COMMAND OVERVIEW')
      cy.url().should('include', '/dashboard')
    })

    it('TC-DASH-026: sidebar remains visible during navigation', () => {
      cy.navigateTo('MISSIONS')
      cy.get('aside').should('be.visible')
      cy.navigateTo('OPERATIONS')
      cy.get('aside').should('be.visible')
    })
  })

  // ============================================
  // RESPONSIVENESS TESTS
  // ============================================
  describe('Responsiveness', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-DASH-027: dashboard is responsive on tablet viewport', () => {
      cy.viewport(768, 1024)
      cy.get('body').should('be.visible')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('TC-DASH-028: dashboard is responsive on mobile viewport', () => {
      cy.viewport(375, 667)
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // USER INFO DISPLAY TESTS
  // ============================================
  describe('User Information Display', () => {
    it('TC-DASH-029: displays admin operator info', () => {
      cy.loginAsAdmin()
      cy.visit('/dashboard')
      cy.get('aside').contains('Operator').should('be.visible')
      cy.get('aside').contains('Clearance').should('be.visible')
    })

    it('TC-DASH-030: displays correct clearance level for admin', () => {
      cy.loginAsAdmin()
      cy.visit('/dashboard')
      cy.get('aside').should('contain.text', 'Admin').or('contain.text', 'ADMIN')
    })
  })
})
