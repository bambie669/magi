// Search E2E Tests
describe('Search (Database Scanner)', () => {
  beforeEach(() => {
    cy.loginAsUser()
  })

  describe('Search Page', () => {
    beforeEach(() => {
      cy.visit('/search')
    })

    it('displays MAGI Database Scanner title', () => {
      cy.contains('MAGI DATABASE SCANNER').should('be.visible')
    })

    it('shows empty state when no query', () => {
      cy.contains('MAGI Database Scanner Ready').should('be.visible')
      cy.contains('Enter a query to search').should('be.visible')
    })

    it('has search input and scan button', () => {
      cy.get('input[name="q"]').should('be.visible')
      cy.contains('SCAN').should('be.visible')
    })
  })

  describe('Global Search from Header', () => {
    beforeEach(() => {
      cy.visit('/dashboard')
    })

    it('can search from header search box', () => {
      cy.get('header input[name="q"]').type('test{enter}')
      cy.url().should('include', '/search')
      cy.url().should('include', 'q=test')
    })
  })

  describe('Search Results', () => {
    it('displays no results message for non-matching query', () => {
      cy.visit('/search?q=xyznonexistent123')
      cy.contains('No results found').should('be.visible')
    })

    it('shows results count for matching query', () => {
      // Use the seeded project data
      cy.visit('/search')
      cy.get('.nerv-panel input[name="q"]').type('EVA-01{enter}')

      cy.contains('Results found').should('be.visible')
      cy.contains('MISSIONS').should('be.visible')
    })

    it('groups results by category', () => {
      cy.visit('/search?q=test')
      // Should show category headers if results exist
      cy.get('body').then(($body) => {
        if ($body.text().includes('Results found')) {
          // Check for category panels
          cy.get('.nerv-panel').should('exist')
        }
      })
    })
  })
})
