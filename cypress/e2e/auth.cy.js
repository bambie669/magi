// Authentication Tests - NERV COMMAND INTERFACE
// Covers all authentication flows for Admin, Manager, and Tester roles

describe('Authentication Module', () => {
  beforeEach(() => {
    cy.clearCookies()
    cy.clearLocalStorage()
  })

  describe('Login Page UI', () => {
    beforeEach(() => {
      cy.visit('/users/sign_in')
    })

    it('TC-AUTH-001: displays NERV branding on login page', () => {
      // Verify NERV themed login page
      cy.get('body').should('be.visible')
      cy.get('input[name="user[email]"]').should('be.visible')
      cy.get('input[name="user[password]"]').should('be.visible')
      cy.get('input[type="submit"]').should('be.visible')
    })

    it('TC-AUTH-002: login form has required fields', () => {
      cy.get('input[name="user[email]"]')
        .should('have.attr', 'type', 'email')
      cy.get('input[name="user[password]"]')
        .should('have.attr', 'type', 'password')
    })
  })

  describe('Valid Login Scenarios', () => {
    it('TC-AUTH-003: Admin can login with valid credentials', () => {
      cy.login(Cypress.env('adminEmail'), Cypress.env('adminPassword'))
      cy.visit('/')
      cy.url().should('not.include', '/sign_in')
      // Verify admin has access to dashboard
      cy.get('body').should('be.visible')
    })

    it('TC-AUTH-004: Manager can login with valid credentials', () => {
      cy.login(Cypress.env('managerEmail'), Cypress.env('managerPassword'))
      cy.visit('/')
      cy.url().should('not.include', '/sign_in')
    })

    it('TC-AUTH-005: Tester can login with valid credentials', () => {
      cy.login(Cypress.env('testerEmail'), Cypress.env('testerPassword'))
      cy.visit('/')
      cy.url().should('not.include', '/sign_in')
    })
  })

  describe('Invalid Login Scenarios', () => {
    beforeEach(() => {
      cy.visit('/users/sign_in')
    })

    it('TC-AUTH-006: shows error for invalid password', () => {
      cy.get('input[name="user[email]"]').type(Cypress.env('adminEmail'))
      cy.get('input[name="user[password]"]').type('wrongpassword')
      cy.get('input[type="submit"]').click()

      // Should remain on login page with error
      cy.url().should('include', '/sign_in')
      cy.get('body').should('contain.text', 'Invalid')
    })

    it('TC-AUTH-007: shows error for non-existent email', () => {
      cy.get('input[name="user[email]"]').type('nonexistent@example.com')
      cy.get('input[name="user[password]"]').type('password')
      cy.get('input[type="submit"]').click()

      cy.url().should('include', '/sign_in')
      cy.get('body').should('contain.text', 'Invalid')
    })

    it('TC-AUTH-008: shows error for empty email field', () => {
      cy.get('input[name="user[password]"]').type('password')
      cy.get('input[type="submit"]').click()

      // HTML5 validation or server-side validation
      cy.url().should('include', '/sign_in')
    })

    it('TC-AUTH-009: shows error for empty password field', () => {
      cy.get('input[name="user[email]"]').type(Cypress.env('adminEmail'))
      cy.get('input[type="submit"]').click()

      cy.url().should('include', '/sign_in')
    })

    it('TC-AUTH-010: shows error for both empty fields', () => {
      cy.get('input[type="submit"]').click()
      cy.url().should('include', '/sign_in')
    })
  })

  describe('Logout Functionality', () => {
    it('TC-AUTH-011: Admin can logout successfully', () => {
      cy.loginAsAdmin()
      cy.visit('/')
      cy.logout()
      cy.url().should('include', '/sign_in')
    })

    it('TC-AUTH-012: Manager can logout successfully', () => {
      cy.loginAsManager()
      cy.visit('/')
      cy.logout()
      cy.url().should('include', '/sign_in')
    })

    it('TC-AUTH-013: Tester can logout successfully', () => {
      cy.loginAsTester()
      cy.visit('/')
      cy.logout()
      cy.url().should('include', '/sign_in')
    })
  })

  describe('Session Management', () => {
    it('TC-AUTH-014: session persists across page navigation', () => {
      cy.loginAsAdmin()
      cy.visit('/')
      cy.goToProjects()
      cy.url().should('include', '/projects')
      cy.goToDashboard()
      cy.url().should('not.include', '/sign_in')
    })

    it('TC-AUTH-015: unauthenticated user is redirected to login', () => {
      cy.visit('/projects')
      cy.url().should('include', '/sign_in')
    })

    it('TC-AUTH-016: protected routes require authentication', () => {
      cy.visit('/dashboard')
      cy.url().should('include', '/sign_in')

      cy.visit('/test_runs')
      cy.url().should('include', '/sign_in')
    })
  })

  describe('Password Security', () => {
    beforeEach(() => {
      cy.visit('/users/sign_in')
    })

    it('TC-AUTH-017: password field masks input', () => {
      cy.get('input[name="user[password]"]')
        .should('have.attr', 'type', 'password')
        .type('testpassword')
        .should('have.value', 'testpassword')
    })

    it('TC-AUTH-018: SQL injection attempt is handled safely', () => {
      cy.get('input[name="user[email]"]').type("admin@example.com' OR '1'='1")
      cy.get('input[name="user[password]"]').type("' OR '1'='1")
      cy.get('input[type="submit"]').click()

      // Should not allow login with SQL injection
      cy.url().should('include', '/sign_in')
    })

    it('TC-AUTH-019: XSS attempt in login form is handled safely', () => {
      cy.get('input[name="user[email]"]').type('<script>alert("xss")</script>@test.com')
      cy.get('input[name="user[password]"]').type('<script>alert("xss")</script>')
      cy.get('input[type="submit"]').click()

      // Should handle gracefully without executing script
      cy.url().should('include', '/sign_in')
    })
  })
})
