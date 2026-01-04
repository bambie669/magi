// Navigation E2E Tests
describe('Navigation', () => {
  beforeEach(() => {
    cy.loginAsUser()
  })

  describe('Sidebar Navigation', () => {
    beforeEach(() => {
      cy.visit('/dashboard')
    })

    it('displays all main navigation items', () => {
      cy.get('aside').within(() => {
        cy.contains('COMMAND OVERVIEW').should('be.visible')
        cy.contains('OPERATIONS').should('be.visible')
        cy.contains('MISSIONS').should('be.visible')
        cy.contains('Analysis').should('be.visible')
        cy.contains('System Config').should('be.visible')
      })
    })

    it('navigates to Command Overview', () => {
      cy.navigateTo('COMMAND OVERVIEW')
      cy.url().should('include', '/dashboard')
    })

    it('navigates to Operations', () => {
      cy.navigateTo('OPERATIONS')
      cy.url().should('include', '/test_runs')
    })

    it('navigates to Missions', () => {
      cy.navigateTo('MISSIONS')
      cy.url().should('include', '/projects')
    })

    it('navigates to Analysis', () => {
      cy.navigateTo('Analysis')
      cy.url().should('include', '/analysis')
    })

    it('navigates to System Config', () => {
      cy.navigateTo('System Config')
      cy.url().should('include', '/system_config')
    })
  })

  describe('Active Missions Section', () => {
    it('displays Active Missions section', () => {
      cy.visit('/dashboard')
      cy.get('aside').contains('Active Missions').should('be.visible')
    })

    it('shows Initialize New link', () => {
      cy.visit('/dashboard')
      cy.get('aside').contains('Initialize New').should('be.visible')
    })

    it('clicking Initialize New goes to new project page', () => {
      cy.visit('/dashboard')
      cy.get('aside').contains('Initialize New').click()
      cy.url().should('include', '/projects/new')
    })
  })

  describe('User Section', () => {
    it('displays Operator label', () => {
      cy.visit('/dashboard')
      cy.get('aside').contains('Operator').should('be.visible')
    })

    it('displays Clearance level', () => {
      cy.visit('/dashboard')
      cy.get('aside').contains('Clearance').should('be.visible')
    })

    it('has logout button', () => {
      cy.visit('/dashboard')
      cy.get('[title="Terminate Session"]').should('be.visible')
    })
  })

  describe('NERV Motto', () => {
    it('displays NERV motto in sidebar', () => {
      cy.visit('/dashboard')
      cy.get('aside').contains("GOD'S IN HIS HEAVEN").should('be.visible')
    })
  })

  describe('Header', () => {
    it('displays page title', () => {
      cy.visit('/dashboard')
      cy.get('header').contains('Interface:').should('be.visible')
    })

    it('displays MAGI status', () => {
      cy.visit('/dashboard')
      cy.get('header').contains('MAGI System Online').should('be.visible')
    })

    it('has search input', () => {
      cy.visit('/dashboard')
      cy.get('header input[placeholder="SCAN DATABASE..."]').should('be.visible')
    })

    it('displays user avatar', () => {
      cy.visit('/dashboard')
      cy.get('header .avatar').should('be.visible')
    })
  })

  describe('Footer', () => {
    it('displays NERV headquarters text', () => {
      cy.visit('/dashboard')
      cy.get('footer').contains('NERV HEADQUARTERS').should('be.visible')
    })

    it('displays system time', () => {
      cy.visit('/dashboard')
      cy.get('footer').contains('SYSTEM TIME:').should('be.visible')
    })
  })
})
