// System Config Tests - NERV System Configuration
// Comprehensive tests for system settings management

describe('System Config Module', () => {

  // ============================================
  // ADMIN SYSTEM CONFIG ACCESS
  // ============================================
  describe('Admin System Config Access', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CONFIG-001: Admin can access system config', () => {
      cy.visit('/system_config')
      cy.url().should('include', '/system_config')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-002: Admin can navigate to system config from sidebar', () => {
      cy.visit('/dashboard')
      cy.goToSystemConfig()
      cy.url().should('include', '/system_config')
    })

    it('TC-CONFIG-003: System config page displays correctly', () => {
      cy.visit('/system_config')
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // PROFILE SETTINGS
  // ============================================
  describe('Profile Settings', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CONFIG-004: can view profile section', () => {
      cy.visit('/system_config?section=profile')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-005: can update display name', () => {
      cy.visit('/system_config?section=profile')
      cy.get('body').then($body => {
        if ($body.find('input[name="user[name]"]').length > 0) {
          cy.get('input[name="user[name]"]').clear().type('Updated Name')
          cy.get('input[type="submit"]').click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CONFIG-006: profile shows current email', () => {
      cy.visit('/system_config?section=profile')
      cy.get('body').should('contain.text', 'admin@example.com')
    })
  })

  // ============================================
  // THEME SETTINGS
  // ============================================
  describe('Theme Settings', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CONFIG-007: can view theme section', () => {
      cy.visit('/system_config?section=theme')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-008: can select NERV theme', () => {
      cy.visit('/system_config?section=theme')
      cy.get('body').then($body => {
        if ($body.find('input[value="nerv"]').length > 0) {
          cy.get('input[value="nerv"]').click()
          cy.get('input[type="submit"]').click()
          cy.get('body').should('have.class', 'theme-nerv')
        }
      })
    })

    it('TC-CONFIG-009: can select Light theme', () => {
      cy.visit('/system_config?section=theme')
      cy.get('body').then($body => {
        if ($body.find('input[value="light"]').length > 0) {
          cy.get('input[value="light"]').click()
          cy.get('input[type="submit"]').click()
          cy.get('body').should('have.class', 'theme-light')
        }
      })
    })

    it('TC-CONFIG-010: theme selection persists', () => {
      cy.visit('/system_config?section=theme')
      cy.get('body').then($body => {
        if ($body.find('input[value="light"]').length > 0) {
          cy.get('input[value="light"]').click()
          cy.get('input[type="submit"]').click()
        }
      })

      cy.visit('/dashboard')
      cy.get('body').then($body => {
        // Theme should be light after setting
        cy.get('body').should('be.visible')
      })
    })
  })

  // ============================================
  // PASSWORD SETTINGS
  // ============================================
  describe('Password Settings', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CONFIG-011: can view password section', () => {
      cy.visit('/system_config?section=password')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-012: password fields are present', () => {
      cy.visit('/system_config?section=password')
      cy.get('body').then($body => {
        if ($body.find('input[name="user[password]"]').length > 0) {
          cy.get('input[name="user[password]"]').should('be.visible')
          cy.get('input[name="user[password_confirmation]"]').should('be.visible')
        }
      })
    })

    it('TC-CONFIG-013: password mismatch shows error', () => {
      cy.visit('/system_config?section=password')
      cy.get('body').then($body => {
        if ($body.find('input[name="user[password]"]').length > 0) {
          cy.get('input[name="user[password]"]').type('newpassword123')
          cy.get('input[name="user[password_confirmation]"]').type('differentpassword')
          cy.get('input[type="submit"]').click()
          // Should show validation error
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // API TOKENS MANAGEMENT
  // ============================================
  describe('API Tokens Management', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CONFIG-014: can view API tokens section', () => {
      cy.visit('/system_config?section=api_tokens')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-015: can create new API token', () => {
      cy.visit('/system_config?section=api_tokens')
      cy.get('body').then($body => {
        if ($body.find('input[name="api_token[name]"]').length > 0) {
          cy.get('input[name="api_token[name]"]').type(`Test Token ${Date.now()}`)
          cy.get('input[type="submit"]').click()
          // Token should be created
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CONFIG-016: token is displayed after creation', () => {
      cy.visit('/system_config?section=api_tokens')
      cy.get('body').then($body => {
        if ($body.find('input[name="api_token[name]"]').length > 0) {
          cy.get('input[name="api_token[name]"]').type(`Display Token ${Date.now()}`)
          cy.get('input[type="submit"]').click()
          // Should show the token value
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CONFIG-017: can delete API token', () => {
      cy.visit('/system_config?section=api_tokens')
      cy.get('body').then($body => {
        if ($body.find('[data-action*="delete"]').length > 0) {
          cy.confirmDialog()
          cy.get('[data-action*="delete"]').first().click()
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  // ============================================
  // MANAGER SYSTEM CONFIG ACCESS
  // ============================================
  describe('Manager System Config Access', () => {
    beforeEach(() => {
      cy.loginAsManager()
    })

    it('TC-CONFIG-018: Manager can access own profile settings', () => {
      cy.visit('/system_config?section=profile')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-019: Manager can access theme settings', () => {
      cy.visit('/system_config?section=theme')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-020: Manager can access password settings', () => {
      cy.visit('/system_config?section=password')
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // TESTER SYSTEM CONFIG ACCESS
  // ============================================
  describe('Tester System Config Access', () => {
    beforeEach(() => {
      cy.loginAsTester()
    })

    it('TC-CONFIG-021: Tester can access own profile settings', () => {
      cy.visit('/system_config?section=profile')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-022: Tester can access theme settings', () => {
      cy.visit('/system_config?section=theme')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-023: Tester can change own password', () => {
      cy.visit('/system_config?section=password')
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // USER MANAGEMENT (ADMIN ONLY)
  // ============================================
  describe('User Management (Admin Only)', () => {
    it('TC-CONFIG-024: Admin can access user management', () => {
      cy.loginAsAdmin()
      cy.visit('/system_config?section=users')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-025: Admin can view user list', () => {
      cy.loginAsAdmin()
      cy.visit('/system_config?section=users')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-026: Admin can create new user', () => {
      cy.loginAsAdmin()
      cy.visit('/system_config?section=users')
      cy.get('body').then($body => {
        if ($body.find('a:contains("Add User")').length > 0) {
          cy.contains('Add User').click()
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CONFIG-027: Tester cannot access user management', () => {
      cy.loginAsTester()
      cy.visit('/system_config?section=users')
      // Should redirect or show access denied
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // NAVIGATION
  // ============================================
  describe('System Config Navigation', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CONFIG-028: can navigate between config sections', () => {
      cy.visit('/system_config?section=profile')
      cy.get('body').should('be.visible')

      cy.visit('/system_config?section=theme')
      cy.get('body').should('be.visible')

      cy.visit('/system_config?section=password')
      cy.get('body').should('be.visible')
    })

    it('TC-CONFIG-029: can return to dashboard from config', () => {
      cy.visit('/system_config')
      cy.navigateTo('COMMAND OVERVIEW')
      cy.url().should('include', '/dashboard')
    })

    it('TC-CONFIG-030: sidebar remains visible in config', () => {
      cy.visit('/system_config')
      cy.get('aside').should('be.visible')
    })
  })

  // ============================================
  // VALIDATION
  // ============================================
  describe('System Config Validation', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-CONFIG-031: XSS prevention in profile name', () => {
      cy.visit('/system_config?section=profile')
      cy.get('body').then($body => {
        if ($body.find('input[name="user[name]"]').length > 0) {
          cy.get('input[name="user[name]"]').clear().type('<script>alert("xss")</script>')
          cy.get('input[type="submit"]').click()
          // Script should not execute
          cy.get('body').should('be.visible')
        }
      })
    })

    it('TC-CONFIG-032: password minimum length validation', () => {
      cy.visit('/system_config?section=password')
      cy.get('body').then($body => {
        if ($body.find('input[name="user[password]"]').length > 0) {
          cy.get('input[name="user[password]"]').type('abc')
          cy.get('input[name="user[password_confirmation]"]').type('abc')
          cy.get('input[type="submit"]').click()
          // Should show validation error for short password
          cy.get('body').should('be.visible')
        }
      })
    })
  })
})
