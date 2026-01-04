// Authentication E2E Tests
describe('Authentication', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  describe('Login Page', () => {
    it('displays NERV branding on login page', () => {
      cy.contains('NERV').should('be.visible')
      cy.contains('MAGI QA SYSTEM').should('be.visible')
      cy.contains('AUTHENTICATION REQUIRED').should('be.visible')
    })

    it('displays the NERV motto', () => {
      cy.contains("GOD'S IN HIS HEAVEN").should('be.visible')
    })

    it('shows login form fields', () => {
      cy.get('input[name="user[email]"]').should('be.visible')
      cy.get('input[name="user[password]"]').should('be.visible')
      cy.get('input[type="submit"]').should('be.visible')
    })

    it('shows error for invalid credentials', () => {
      cy.get('input[name="user[email]"]').type('invalid@example.com')
      cy.get('input[name="user[password]"]').type('wrongpassword')
      cy.get('input[type="submit"]').click()
      cy.contains('Invalid Email or password').should('be.visible')
    })
  })

  describe('Successful Login', () => {
    it('redirects to dashboard after login', () => {
      cy.loginAsUser()
      // The authenticated root path redirects to dashboard or root
      cy.url().should('satisfy', (url) => url.includes('/dashboard') || url === 'http://localhost:2507/')
    })

    it('displays user information in sidebar', () => {
      cy.loginAsUser()
      cy.get('aside').contains('Operator').should('be.visible')
      cy.get('aside').contains('Clearance').should('be.visible')
    })

    it('shows MAGI System Online status', () => {
      cy.loginAsUser()
      cy.contains('MAGI System Online').should('be.visible')
    })
  })

  describe('Logout', () => {
    it('can logout and returns to login page', () => {
      cy.loginAsUser()
      cy.visit('/dashboard')
      // Find and click the logout button (button with Terminate Session title)
      cy.get('button[title="Terminate Session"]').click()
      // After logout, should show login form
      cy.contains('AUTHENTICATION REQUIRED').should('be.visible')
      cy.get('input[name="user[email]"]').should('be.visible')
    })
  })

  describe('Protected Routes', () => {
    it('redirects to login when accessing dashboard without auth', () => {
      cy.visit('/dashboard')
      cy.url().should('include', '/sign_in')
    })

    it('redirects to login when accessing projects without auth', () => {
      cy.visit('/projects')
      cy.url().should('include', '/sign_in')
    })

    it('redirects to login when accessing test runs without auth', () => {
      cy.visit('/test_runs')
      cy.url().should('include', '/sign_in')
    })
  })
})
