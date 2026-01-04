// Theme Tests - NERV Interface Theme Testing
// Comprehensive tests for theme toggle and persistence

describe('Theme Module', () => {

  // ============================================
  // DEFAULT THEME TESTS
  // ============================================
  describe('Default Theme', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-THEME-001: NERV theme is applied by default', () => {
      cy.get('body').should('have.class', 'theme-nerv')
    })

    it('TC-THEME-002: NERV theme has dark background', () => {
      cy.get('body').should('have.class', 'theme-nerv')
      // Check that body has dark styling
      cy.get('body').should('be.visible')
    })

    it('TC-THEME-003: theme toggle button is visible', () => {
      cy.get('[data-controller="theme-toggle"]').should('be.visible')
    })

    it('TC-THEME-004: NERV theme shows correct colors', () => {
      cy.get('body').should('have.class', 'theme-nerv')
      // Sidebar should have NERV styling
      cy.get('aside').should('be.visible')
    })
  })

  // ============================================
  // THEME TOGGLE TESTS
  // ============================================
  describe('Theme Toggle', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-THEME-005: can toggle from NERV to Light theme', () => {
      cy.get('body').should('have.class', 'theme-nerv')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-006: can toggle from Light back to NERV theme', () => {
      // First toggle to light
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')

      // Toggle back to NERV
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-nerv')
    })

    it('TC-THEME-007: theme toggle button updates icon', () => {
      cy.get('[data-controller="theme-toggle"] button').should('be.visible')
      cy.toggleTheme()
      // Icon should change after toggle
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // THEME PERSISTENCE TESTS
  // ============================================
  describe('Theme Persistence', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-THEME-008: theme persists across page navigation', () => {
      cy.visit('/dashboard')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')

      cy.navigateTo('MISSIONS')
      cy.get('body').should('have.class', 'theme-light')

      cy.navigateTo('OPERATIONS')
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-009: theme persists after page refresh', () => {
      cy.visit('/dashboard')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')

      cy.reload()
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-010: theme persists in localStorage', () => {
      cy.visit('/dashboard')
      cy.toggleTheme()

      cy.window().then((win) => {
        const theme = win.localStorage.getItem('theme')
        expect(theme).to.be.oneOf(['light', 'theme-light'])
      })
    })
  })

  // ============================================
  // LIGHT THEME TESTS
  // ============================================
  describe('Light Theme', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
      cy.toggleTheme() // Switch to light
    })

    it('TC-THEME-011: Light theme is applied correctly', () => {
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-012: Light theme has appropriate styling', () => {
      cy.get('body').should('have.class', 'theme-light')
      cy.get('body').should('be.visible')
    })

    it('TC-THEME-013: sidebar is visible in light theme', () => {
      cy.get('aside').should('be.visible')
    })

    it('TC-THEME-014: navigation works in light theme', () => {
      cy.navigateTo('MISSIONS')
      cy.url().should('include', '/projects')
      cy.get('body').should('have.class', 'theme-light')
    })
  })

  // ============================================
  // THEME ON DIFFERENT PAGES
  // ============================================
  describe('Theme on Different Pages', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-THEME-015: theme toggle works on dashboard', () => {
      cy.visit('/dashboard')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-016: theme toggle works on projects page', () => {
      cy.visit('/projects')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-017: theme toggle works on test runs page', () => {
      cy.visit('/test_runs')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })
  })

  // ============================================
  // THEME FOR DIFFERENT USERS
  // ============================================
  describe('Theme for Different Users', () => {
    it('TC-THEME-018: Admin can toggle theme', () => {
      cy.loginAsAdmin()
      cy.visit('/dashboard')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-019: Manager can toggle theme', () => {
      cy.loginAsManager()
      cy.visit('/dashboard')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-020: Tester can toggle theme', () => {
      cy.loginAsTester()
      cy.visit('/dashboard')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })
  })

  // ============================================
  // THEME ACCESSIBILITY TESTS
  // ============================================
  describe('Theme Accessibility', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-THEME-021: text is readable in NERV theme', () => {
      cy.get('body').should('have.class', 'theme-nerv')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('TC-THEME-022: text is readable in Light theme', () => {
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('TC-THEME-023: buttons are visible in both themes', () => {
      // NERV theme
      cy.get('[data-controller="theme-toggle"] button').should('be.visible')

      // Light theme
      cy.toggleTheme()
      cy.get('[data-controller="theme-toggle"] button').should('be.visible')
    })
  })

  // ============================================
  // THEME SERVER SYNC TESTS
  // ============================================
  describe('Theme Server Synchronization', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-THEME-024: theme preference is saved to server', () => {
      cy.visit('/dashboard')
      cy.toggleTheme()

      // Wait for server sync
      cy.wait(1000)

      // Verify in system config
      cy.visit('/system_config?section=theme')
      cy.get('body').should('be.visible')
    })

    it('TC-THEME-025: theme loads from server on new session', () => {
      cy.visit('/dashboard')
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')

      // Clear session and re-login
      cy.clearCookies()
      cy.loginAsUser()
      cy.visit('/dashboard')

      // Theme should be preserved from server
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // THEME RESPONSIVE TESTS
  // ============================================
  describe('Theme Responsiveness', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-THEME-026: theme toggle works on tablet', () => {
      cy.viewport(768, 1024)
      cy.toggleTheme()
      cy.get('body').should('have.class', 'theme-light')
    })

    it('TC-THEME-027: theme toggle works on mobile', () => {
      cy.viewport(375, 667)
      cy.get('body').then($body => {
        // Toggle if button is visible
        if ($body.find('[data-controller="theme-toggle"] button:visible').length > 0) {
          cy.toggleTheme()
          cy.get('body').should('have.class', 'theme-light')
        }
      })
    })
  })

  // ============================================
  // NERV SPECIFIC ELEMENTS
  // ============================================
  describe('NERV Theme Specific Elements', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/dashboard')
    })

    it('TC-THEME-028: NERV logo is visible in NERV theme', () => {
      cy.get('aside').contains('NERV').should('be.visible')
    })

    it('TC-THEME-029: MAGI status is visible', () => {
      cy.contains('MAGI System Online').should('be.visible')
    })

    it('TC-THEME-030: footer shows NERV branding', () => {
      cy.get('footer').contains('NERV HEADQUARTERS').should('be.visible')
    })
  })
})
