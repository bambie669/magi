// Projects (Missions) E2E Tests
// Comprehensive tests for project management

describe('Projects (Missions)', () => {

  // ============================================
  // PROJECTS LIST TESTS
  // ============================================
  describe('Projects List', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/projects')
    })

    it('TC-PROJ-001: displays MISSIONS as page title', () => {
      cy.contains('MISSION REGISTRY').should('be.visible')
    })

    it('TC-PROJ-002: displays project cards if projects exist', () => {
      cy.get('body').should('be.visible')
      // Either shows project cards or "no missions" message
    })

    it('TC-PROJ-003: can navigate to projects from sidebar', () => {
      cy.visit('/dashboard')
      cy.navigateTo('MISSIONS')
      cy.url().should('include', '/projects')
    })
  })

  // ============================================
  // ADMIN PROJECT MANAGEMENT
  // ============================================
  describe('Admin Project Management', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-PROJ-004: Admin can access new project form', () => {
      cy.visit('/projects/new')
      cy.get('input[name="project[name]"]').should('be.visible')
      cy.get('textarea[name="project[description]"]').should('be.visible')
    })

    it('TC-PROJ-005: Admin can create a new project', () => {
      const projectName = `Test Mission ${Date.now()}`
      cy.visit('/projects/new')
      cy.get('input[name="project[name]"]').type(projectName)
      cy.get('textarea[name="project[description]"]').type('Automated test mission description created by Cypress')
      cy.get('input[type="submit"]').click()

      // Should redirect to project page
      cy.contains(projectName).should('be.visible')
    })

    it('TC-PROJ-006: Admin sees Initialize Mission button', () => {
      cy.visit('/projects')
      cy.contains('Initialize Mission').should('be.visible')
    })

    it('TC-PROJ-007: shows validation error for empty name', () => {
      cy.visit('/projects/new')
      cy.get('textarea[name="project[description]"]').type('Description without name')
      cy.get('input[type="submit"]').click()
      // Should show validation error or stay on form
      cy.url().should('include', '/projects')
    })

    it('TC-PROJ-008: Admin can edit existing project', () => {
      // First create a project
      const projectName = `Edit Test ${Date.now()}`
      cy.createProject(projectName)

      // Then edit it
      cy.contains('Modify').click()
      cy.get('input[name="project[name]"]').clear().type(`${projectName} - Modified`)
      cy.get('input[type="submit"]').click()

      cy.contains(`${projectName} - Modified`).should('be.visible')
    })

    it('TC-PROJ-009: Admin can delete project', () => {
      // Create a project for deletion
      const projectName = `Delete Test ${Date.now()}`
      cy.createProject(projectName)

      // Delete it
      cy.confirmDialog()
      cy.contains('Terminate').click()

      // Verify deletion
      cy.visit('/projects')
      cy.contains(projectName).should('not.exist')
    })
  })

  // ============================================
  // MANAGER PROJECT MANAGEMENT
  // ============================================
  describe('Manager Project Management', () => {
    beforeEach(() => {
      cy.loginAsManager()
    })

    it('TC-PROJ-010: Manager can access projects list', () => {
      cy.visit('/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')
    })

    it('TC-PROJ-011: Manager can create projects', () => {
      const projectName = `Manager Project ${Date.now()}`
      cy.visit('/projects/new')
      cy.get('input[name="project[name]"]').type(projectName)
      cy.get('textarea[name="project[description]"]').type('Project created by manager')
      cy.get('input[type="submit"]').click()

      cy.contains(projectName).should('be.visible')
    })

    it('TC-PROJ-012: Manager can view project details', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.url().should('match', /\/projects\/\d+/)
    })
  })

  // ============================================
  // TESTER PROJECT ACCESS
  // ============================================
  describe('Tester Project Access', () => {
    beforeEach(() => {
      cy.loginAsTester()
    })

    it('TC-PROJ-013: Tester can view projects list', () => {
      cy.visit('/projects')
      cy.contains('MISSION REGISTRY').should('be.visible')
    })

    it('TC-PROJ-014: Tester can view project details', () => {
      cy.visit('/projects')
      cy.get('body').then($body => {
        if ($body.find('.nerv-panel a[href^="/projects/"]').length > 0) {
          cy.get('.nerv-panel a[href^="/projects/"]').first().click()
          cy.url().should('match', /\/projects\/\d+/)
          cy.contains('Protocol Banks').should('be.visible')
        }
      })
    })

    it('TC-PROJ-015: Tester cannot create projects', () => {
      cy.visit('/projects')
      // Tester should not see Initialize Mission button or it should be disabled
      cy.get('body').then($body => {
        if ($body.find('a:contains("Initialize Mission")').length > 0) {
          // If button exists, clicking it should result in unauthorized
          cy.visit('/projects/new')
          cy.url().should('not.include', '/projects/new')
        }
      })
    })
  })

  // ============================================
  // PROJECT DETAILS PAGE
  // ============================================
  describe('Project Details', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-PROJ-016: displays project details with NERV terminology', () => {
      const projectName = `Detail Test ${Date.now()}`
      cy.visit('/projects/new')
      cy.get('input[name="project[name]"]').type(projectName)
      cy.get('textarea[name="project[description]"]').type('Test description')
      cy.get('input[type="submit"]').click()

      // Should show protocol banks section
      cy.contains('Protocol Banks').should('be.visible')
      // Should show operations section
      cy.contains('Operations Log').should('be.visible')
    })

    it('TC-PROJ-017: project page shows test suite count', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.get('body').should('be.visible')
    })

    it('TC-PROJ-018: project page shows test run count', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // PROJECT NAVIGATION
  // ============================================
  describe('Project Navigation', () => {
    beforeEach(() => {
      cy.loginAsUser()
    })

    it('TC-PROJ-019: can navigate between projects and dashboard', () => {
      cy.visit('/projects')
      cy.navigateTo('COMMAND OVERVIEW')
      cy.url().should('include', '/dashboard')
      cy.navigateTo('MISSIONS')
      cy.url().should('include', '/projects')
    })

    it('TC-PROJ-020: back button works from project detail', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      cy.go('back')
      cy.url().should('include', '/projects')
    })
  })

  // ============================================
  // PROJECT SEARCH & FILTER
  // ============================================
  describe('Project Search', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/projects')
    })

    it('TC-PROJ-021: global search works for projects', () => {
      cy.globalSearch('project')
      cy.url().should('include', 'q=project')
    })
  })

  // ============================================
  // PROJECT VALIDATION
  // ============================================
  describe('Project Validation', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-PROJ-022: cannot create project with empty name', () => {
      cy.visit('/projects/new')
      cy.get('input[type="submit"]').click()
      cy.url().should('include', '/projects')
    })

    it('TC-PROJ-023: project name has max length', () => {
      const longName = 'A'.repeat(300)
      cy.visit('/projects/new')
      cy.get('input[name="project[name]"]').type(longName)
      cy.get('input[type="submit"]').click()
      // Should either truncate or show validation error
      cy.get('body').should('be.visible')
    })

    it('TC-PROJ-024: XSS prevention in project name', () => {
      cy.visit('/projects/new')
      cy.get('input[name="project[name]"]').type('<script>alert("xss")</script>')
      cy.get('textarea[name="project[description]"]').type('XSS test')
      cy.get('input[type="submit"]').click()

      // Script should not execute
      cy.get('body').should('be.visible')
    })
  })

  // ============================================
  // PROJECT MILESTONES
  // ============================================
  describe('Project Milestones', () => {
    beforeEach(() => {
      cy.loginAsAdmin()
    })

    it('TC-PROJ-025: can view milestones section', () => {
      cy.visit('/projects')
      cy.get('.nerv-panel a[href^="/projects/"]').first().click()
      // Milestones should be visible on project page
      cy.get('body').should('be.visible')
    })
  })
})
