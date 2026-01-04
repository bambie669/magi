// Analysis E2E Tests
describe('Analysis (System Analysis)', () => {
  beforeEach(() => {
    cy.loginAsUser()
    cy.visit('/analysis')
  })

  describe('Page Structure', () => {
    it('displays SYSTEM ANALYSIS as page title', () => {
      cy.contains('SYSTEM ANALYSIS').should('be.visible')
    })

    it('displays MAGI Analysis Module header', () => {
      cy.contains('MAGI Analysis Module').should('be.visible')
    })

    it('shows Analysis Complete status', () => {
      cy.contains('Analysis Complete').should('be.visible')
    })
  })

  describe('Key Metrics', () => {
    it('displays MISSIONS metric', () => {
      cy.contains('MISSIONS').should('be.visible')
    })

    it('displays PROTOCOL BANKS metric', () => {
      cy.contains('PROTOCOL BANKS').should('be.visible')
    })

    it('displays PROTOCOLS metric', () => {
      cy.contains('PROTOCOLS').should('be.visible')
    })

    it('displays OPERATIONS metric', () => {
      cy.contains('OPERATIONS').should('be.visible')
    })
  })

  describe('System Integrity Report', () => {
    it('displays System Integrity Report panel', () => {
      cy.contains('SYSTEM INTEGRITY REPORT').should('be.visible')
    })

    it('displays status categories', () => {
      cy.contains('NOMINAL').should('be.visible')
      cy.contains('BREACH').should('be.visible')
      cy.contains('PATTERN BLUE').should('be.visible')
      cy.contains('STANDBY').should('be.visible')
    })

    it('displays pass rate', () => {
      cy.contains('Overall Pass Rate').should('be.visible')
    })
  })

  describe('MAGI Consensus', () => {
    it('displays MAGI Consensus panel', () => {
      cy.contains('MAGI CONSENSUS').should('be.visible')
    })

    it('displays all three MAGI systems', () => {
      cy.contains('CASPER').should('be.visible')
      cy.contains('BALTHASAR').should('be.visible')
      cy.contains('MELCHIOR').should('be.visible')
    })

    it('displays verdict', () => {
      cy.contains('Verdict').should('be.visible')
    })
  })

  describe('Charts and Data', () => {
    it('displays Operations by Mission section', () => {
      cy.contains('OPERATIONS BY MISSION').should('be.visible')
    })

    it('displays Execution Telemetry section', () => {
      cy.contains('EXECUTION TELEMETRY').should('be.visible')
    })

    it('displays Top Missions section', () => {
      cy.contains('TOP MISSIONS BY PROTOCOLS').should('be.visible')
    })

    it('displays Recent Operations section', () => {
      cy.contains('RECENT OPERATIONS').should('be.visible')
    })
  })
})
