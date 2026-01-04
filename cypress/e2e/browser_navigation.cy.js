// Browser Navigation E2E Tests - Testing back button functionality
describe('Browser Navigation (Back Button)', () => {
  beforeEach(() => {
    cy.loginAsUser()
  })

  describe('Dashboard to Projects and Back', () => {
    it('navigates to projects and back to dashboard', () => {
      cy.visit('/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')

      // Navigate to projects
      cy.navigateTo('MISSIONS')
      cy.url().should('include', '/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Go back
      cy.go('back')
      cy.url().should('include', '/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('navigates to operations and back to dashboard', () => {
      cy.visit('/dashboard')

      // Navigate to operations
      cy.navigateTo('OPERATIONS')
      cy.url().should('include', '/test_runs')

      // Go back
      cy.go('back')
      cy.url().should('include', '/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('navigates to analysis and back to dashboard', () => {
      cy.visit('/dashboard')

      // Navigate to analysis
      cy.navigateTo('Analysis')
      cy.url().should('include', '/analysis')
      cy.contains('SYSTEM ANALYSIS').should('be.visible')

      // Go back
      cy.go('back')
      cy.url().should('include', '/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })
  })

  describe('Project Details Navigation', () => {
    it('navigates to project details and back to projects list', () => {
      cy.visit('/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Click on first project
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.url().should('match', /\/projects\/\d+/)
      cy.contains('Protocol Banks').should('be.visible')

      // Go back to projects list
      cy.go('back')
      cy.wait(300) // Wait for Turbo to restore
      cy.contains('MISSION REGISTRY').should('be.visible')
    })

    it('navigates dashboard -> projects -> project detail -> back -> back', () => {
      cy.visit('/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')

      // Go to projects
      cy.navigateTo('MISSIONS')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Go to project detail
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.url().should('match', /\/projects\/\d+/)
      cy.contains('Protocol Banks').should('be.visible')

      // Back to projects list
      cy.go('back')
      cy.wait(300)
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Back to dashboard
      cy.go('back')
      cy.wait(300)
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })
  })

  describe('Search Navigation', () => {
    it('searches and goes back', () => {
      cy.visit('/dashboard')

      // Perform search from header
      cy.get('header input[name="q"]').type('EVA{enter}')
      cy.url().should('include', '/search')
      cy.contains('Results found').should('be.visible')

      // Go back to dashboard
      cy.go('back')
      cy.url().should('include', '/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })

    it('searches, clicks result, and navigates back twice', () => {
      cy.visit('/search')
      cy.get('.nerv-panel input[name="q"]').type('Test{enter}')
      cy.contains('Results found').should('be.visible')

      // Click on a project search result (filter by numeric ID in URL)
      cy.get('a[href^="/projects/"]').filter(':not([href$="/new"])').first().click()
      cy.url().should('match', /\/projects\/\d+/)

      // Back to search results
      cy.go('back')
      cy.url().should('include', '/search')

      // Back again
      cy.go('back')
      cy.url().should('include', '/search')
    })
  })

  describe('Test Runs Navigation', () => {
    it('navigates to test run details and back', () => {
      cy.visit('/test_runs')

      // Check if there are test runs
      cy.get('body').then(($body) => {
        if ($body.text().includes('Initial Activation Test')) {
          cy.contains('Initial Activation Test').click()
          cy.url().should('match', /\/test_runs\/\d+/)

          // Go back
          cy.go('back')
          cy.url().should('include', '/test_runs')
        }
      })
    })
  })

  describe('Multiple Sequential Navigation', () => {
    it('navigates through multiple pages and back through all', () => {
      // Start at dashboard
      cy.visit('/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')

      // Go to projects
      cy.navigateTo('MISSIONS')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Go to operations
      cy.navigateTo('OPERATIONS')
      cy.url().should('include', '/test_runs')

      // Go to analysis
      cy.navigateTo('Analysis')
      cy.contains('SYSTEM ANALYSIS').should('be.visible')

      // Go to system config
      cy.navigateTo('System Config')
      cy.url().should('include', '/system_config')

      // Now go back through all pages
      cy.go('back')
      cy.contains('SYSTEM ANALYSIS').should('be.visible')

      cy.go('back')
      cy.url().should('include', '/test_runs')

      cy.go('back')
      cy.contains('MISSION REGISTRY').should('be.visible')

      cy.go('back')
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })
  })

  describe('Forward Navigation', () => {
    it('can go back and forward', () => {
      cy.visit('/dashboard')

      // Navigate to projects
      cy.navigateTo('MISSIONS')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Go back
      cy.go('back')
      cy.contains('COMMAND OVERVIEW').should('be.visible')

      // Go forward
      cy.go('forward')
      cy.contains('MISSION REGISTRY').should('be.visible')
    })
  })

  describe('Rapid Navigation', () => {
    it('handles rapid back button clicks', () => {
      cy.visit('/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')

      cy.navigateTo('MISSIONS')
      cy.contains('MISSION REGISTRY').should('be.visible')

      cy.navigateTo('OPERATIONS')
      cy.url().should('include', '/test_runs')

      cy.navigateTo('Analysis')
      cy.contains('SYSTEM ANALYSIS').should('be.visible')

      // Back navigation with waits
      cy.go('back')
      cy.wait(200)
      cy.go('back')
      cy.wait(200)
      cy.go('back')
      cy.wait(200)

      // Should end up at dashboard
      cy.contains('COMMAND OVERVIEW').should('be.visible')
    })
  })

  describe('Page State After Navigation', () => {
    it('maintains page state after back navigation', () => {
      cy.visit('/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Go to project detail
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Protocol Banks').should('be.visible')

      // Go back
      cy.go('back')
      cy.wait(300)

      // Page should be fully rendered
      cy.contains('MISSION REGISTRY').should('be.visible')
      cy.get('.nerv-panel').should('exist')
      cy.get('.nerv-panel a[href^="/projects/"]').should('have.length.at.least', 1)
    })

    it('sidebar remains functional after back navigation', () => {
      cy.visit('/dashboard')
      cy.navigateTo('MISSIONS')
      cy.go('back')

      // Sidebar should still work
      cy.get('aside').should('be.visible')
      cy.navigateTo('Analysis')
      cy.contains('SYSTEM ANALYSIS').should('be.visible')
    })
  })
})
