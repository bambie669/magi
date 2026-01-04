/**
 * Exemplu de teste Cypress cu ID-uri pentru Magi QA
 *
 * CONVENȚIE: Titlul testului trebuie să înceapă cu ID-ul din Magi
 *
 * Formate acceptate:
 *   - "TC-001: Description"
 *   - "TC-001 - Description"
 *   - "[TC-001] Description"
 *   - "MAGI-001: Description"
 */

describe('Login Feature', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('TC-001: should display login form', () => {
    cy.get('input[name="email"]').should('be.visible');
    cy.get('input[name="password"]').should('be.visible');
    cy.get('button[type="submit"]').should('contain', 'Login');
  });

  it('TC-002: should login with valid credentials', () => {
    cy.get('input[name="email"]').type('user@example.com');
    cy.get('input[name="password"]').type('password123');
    cy.get('button[type="submit"]').click();

    cy.url().should('include', '/dashboard');
    cy.contains('Welcome').should('be.visible');
  });

  it('TC-003: should show error for invalid credentials', () => {
    cy.get('input[name="email"]').type('user@example.com');
    cy.get('input[name="password"]').type('wrongpassword');
    cy.get('button[type="submit"]').click();

    cy.contains('Invalid email or password').should('be.visible');
  });

  it('TC-004: should redirect to forgot password page', () => {
    cy.contains('Forgot password?').click();
    cy.url().should('include', '/forgot-password');
  });
});

describe('Registration Feature', () => {
  it('[TC-010] should display registration form', () => {
    cy.visit('/register');

    cy.get('input[name="email"]').should('be.visible');
    cy.get('input[name="password"]').should('be.visible');
    cy.get('input[name="password_confirmation"]').should('be.visible');
  });

  it('TC-011 - should register new user successfully', () => {
    cy.visit('/register');

    cy.get('input[name="email"]').type('newuser@example.com');
    cy.get('input[name="password"]').type('securepassword');
    cy.get('input[name="password_confirmation"]').type('securepassword');
    cy.get('button[type="submit"]').click();

    cy.url().should('include', '/dashboard');
  });
});

// Test fără ID - nu va fi trimis la Magi
describe('Other tests', () => {
  it('should do something without tracking', () => {
    cy.log('This test has no cypress_id and will not be sent to Magi');
  });
});
