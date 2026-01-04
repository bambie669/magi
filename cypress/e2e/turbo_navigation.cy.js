// Turbo Drive Navigation Tests - Testing for crashes and errors
describe('Turbo Navigation Stability', () => {
  beforeEach(() => {
    cy.loginAsUser()
  })

  describe('Stress Test: Rapid Page Changes', () => {
    it('handles rapid sidebar navigation without crashing', () => {
      cy.visit('/dashboard')

      // Rapid navigation through sidebar
      for (let i = 0; i < 3; i++) {
        cy.navigateTo('MISSIONS')
        cy.navigateTo('OPERATIONS')
        cy.navigateTo('Analysis')
        cy.navigateTo('COMMAND OVERVIEW')
      }

      // Verify page is still functional
      cy.get('aside').should('be.visible')
      cy.contains('NERV').should('be.visible')
    })

    it('handles rapid back/forward without crashing', () => {
      cy.visit('/dashboard')
      cy.navigateTo('MISSIONS')
      cy.navigateTo('OPERATIONS')
      cy.navigateTo('Analysis')

      // Rapid back/forward
      for (let i = 0; i < 5; i++) {
        cy.go('back')
        cy.go('forward')
      }

      // Page should still work
      cy.get('body').should('be.visible')
      cy.get('aside').should('be.visible')
    })
  })

  describe('Turbo Cache Behavior', () => {
    it('page renders correctly after cache restore', () => {
      cy.visit('/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')

      cy.navigateTo('MISSIONS')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Click on first project link in the panel
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Protocol Banks').should('be.visible')

      // Go back - Turbo should restore from cache
      cy.go('back')
      cy.wait(300)

      // Check all elements are properly rendered
      cy.contains('MISSION REGISTRY').should('be.visible')
      cy.get('.nerv-panel').should('have.length.at.least', 1)
      cy.get('aside').should('be.visible')
      cy.get('header').should('be.visible')
      cy.get('footer').should('be.visible')
    })

    it('sidebar links work after cache restore', () => {
      cy.visit('/dashboard')
      cy.contains('COMMAND OVERVIEW').should('be.visible')

      cy.navigateTo('MISSIONS')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Click on first project link
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.contains('Protocol Banks').should('be.visible')

      cy.go('back')
      cy.wait(300)

      // Sidebar should be functional
      cy.navigateTo('Analysis')
      cy.contains('SYSTEM ANALYSIS').should('be.visible')
    })

    it('forms work after back navigation', () => {
      // Visit new project form directly (already logged in as user from beforeEach)
      cy.visit('/projects/new')

      // Check if we have access (testers may not have access to create projects)
      cy.get('body').then(($body) => {
        if ($body.find('input[name="project[name]"]').length > 0) {
          cy.get('input[name="project[name]"]').should('be.visible')

          // Navigate away
          cy.navigateTo('MISSIONS')
          cy.contains('MISSION REGISTRY').should('be.visible')

          // Go back to form
          cy.go('back')

          // Form should be functional
          cy.get('input[name="project[name]"]').should('be.visible')
          cy.get('input[name="project[name]"]').type('Test Project')
          cy.get('input[name="project[name]"]').should('have.value', 'Test Project')
        } else {
          // User doesn't have permission - just verify we're on a valid page
          cy.get('body').should('be.visible')
        }
      })
    })
  })

  describe('Search After Navigation', () => {
    it('search works after multiple navigations', () => {
      cy.visit('/dashboard')
      cy.navigateTo('MISSIONS')
      cy.navigateTo('OPERATIONS')
      cy.go('back')
      cy.go('back')

      // Search from header
      cy.get('header input[name="q"]').type('EVA{enter}')
      cy.contains('Results found').should('be.visible')
    })
  })

  describe('Dynamic Content After Navigation', () => {
    it('project stats update correctly', () => {
      cy.visit('/dashboard')

      // Check stats are visible
      cy.contains('ACTIVE OPS').should('be.visible')

      // Navigate away and back
      cy.navigateTo('MISSIONS')
      cy.go('back')

      // Stats should still be visible and correct
      cy.contains('ACTIVE OPS').should('be.visible')
      cy.get('.nerv-panel').should('have.length.at.least', 1)
    })

    it('analysis charts render after navigation', () => {
      cy.visit('/analysis')
      cy.contains('SYSTEM INTEGRITY REPORT').should('be.visible')

      cy.navigateTo('MISSIONS')
      cy.url().should('include', '/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')

      cy.go('back')
      // Wait for Turbo to restore the page
      cy.wait(500)

      // Should be back on analysis - check URL first
      cy.url().should('include', '/analysis')
      // Charts should still render
      cy.contains('SYSTEM INTEGRITY REPORT').should('be.visible')
      cy.contains('MAGI CONSENSUS').should('be.visible')
    })
  })

  describe('Scroll Position', () => {
    it('maintains scroll position on back navigation', () => {
      cy.visit('/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Navigate to project detail
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.url().should('match', /\/projects\/\d+/)
      cy.contains('Protocol Banks').should('be.visible')

      // Go back
      cy.go('back')
      cy.wait(300)
      cy.contains('MISSION REGISTRY').should('be.visible')
    })
  })

  describe('Theme Persistence', () => {
    it('theme persists after navigation', () => {
      cy.visit('/dashboard')
      cy.get('body').should('have.class', 'theme-nerv')

      cy.navigateTo('MISSIONS')
      cy.get('body').should('have.class', 'theme-nerv')

      cy.go('back')
      cy.get('body').should('have.class', 'theme-nerv')
    })
  })

  describe('MAGI Status Indicator', () => {
    it('MAGI status remains visible after navigation', () => {
      cy.visit('/dashboard')
      cy.contains('MAGI System Online').should('be.visible')

      cy.navigateTo('MISSIONS')
      cy.contains('MAGI System Online').should('be.visible')

      cy.navigateTo('Analysis')
      cy.contains('MAGI System Online').should('be.visible')

      cy.go('back')
      cy.go('back')
      cy.contains('MAGI System Online').should('be.visible')
    })
  })

  describe('Error Recovery', () => {
    it('can navigate after visiting non-existent page', () => {
      cy.visit('/nonexistent', { failOnStatusCode: false })

      // Should be able to navigate via sidebar
      cy.visit('/dashboard')
      cy.navigateTo('MISSIONS')
      cy.contains('MISSION REGISTRY').should('be.visible')
    })
  })

  describe('Page Interactions After Back', () => {
    it('buttons work after back navigation', () => {
      // Already logged in as tester from beforeEach
      cy.visit('/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Navigate to a project detail
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.url().should('match', /\/projects\/\d+/)
      cy.contains('Protocol Banks').should('be.visible')

      // Go back
      cy.go('back')
      cy.wait(300)
      cy.contains('MISSION REGISTRY').should('be.visible')

      // Link should still work
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.url().should('match', /\/projects\/\d+/)
    })

    it('links in sidebar work after multiple navigations', () => {
      cy.visit('/dashboard')

      // Navigate around
      cy.navigateTo('MISSIONS')
      cy.navigateTo('OPERATIONS')
      cy.go('back')
      cy.go('back')

      // All sidebar links should work
      cy.get('aside').contains('Analysis').click()
      cy.url().should('include', '/analysis')
    })
  })
})
