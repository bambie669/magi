# db/seeds.rb

# Șterge datele existente pentru a evita duplicatele la re-rulare (opțional)
puts "Cleaning database..."
User.destroy_all
Project.destroy_all
# Milestones, TestSuites, TestCases, TestRuns, TestRunCases vor fi șterse prin dependent: :destroy

puts "Creating Admin User..."
admin_user = User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: :admin
)
puts "Admin User created: #{admin_user.email}"

puts "Creating Tester User..."
tester_user = User.create!(
  email: 'tester@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: :tester
)
puts "Tester User created: #{tester_user.email}"

puts "Creating Manager User..."
manager_user = User.create!(
  email: 'manager@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: :manager
)
puts "Manager User created: #{manager_user.email}"


puts "Creating Project..."
project = Project.create!(
  name: 'E-commerce Platform',
  description: 'Testing for the new online store.',
  user: manager_user # Creat de manager
)
puts "Project created: #{project.name}"

puts "Creating Milestones..."
milestone1 = project.milestones.create!(name: 'Phase 1 - Launch', due_date: Date.today + 30.days)
milestone2 = project.milestones.create!(name: 'Phase 2 - Mobile App', due_date: Date.today + 90.days)
puts "Milestones created."

puts "Creating Test Suites..."
suite_auth = project.test_suites.create!(name: 'Authentication', description: 'Tests for user login, registration, password reset.')
suite_cart = project.test_suites.create!(name: 'Shopping Cart', description: 'Tests related to adding, removing, and updating cart items.')
puts "Test Suites created."

puts "Creating Test Scopes and Test Cases..."
# Create default scope for Authentication Suite
scope_auth = suite_auth.test_scopes.create!(name: 'Login Tests')
scope_auth.test_cases.create!(
  title: 'TC-AUTH-001: Valid User Login',
  preconditions: 'User account exists and is active. Site is accessible.',
  steps: "1. Navigate to Login page.\n2. Enter valid email.\n3. Enter valid password.\n4. Click Login button.",
  expected_result: 'User is successfully logged in and redirected to their dashboard.',
  cypress_id: 'TC-AUTH-001'
)
scope_auth.test_cases.create!(
  title: 'TC-AUTH-002: Invalid User Login - Wrong Password',
  preconditions: 'User account exists. Site is accessible.',
  steps: "1. Navigate to Login page.\n2. Enter valid email.\n3. Enter invalid password.\n4. Click Login button.",
  expected_result: 'Error message indicating invalid credentials is displayed. User remains on login page.',
  cypress_id: 'TC-AUTH-002'
)

# Create default scope for Shopping Cart Suite
scope_cart = suite_cart.test_scopes.create!(name: 'Cart Operations')
scope_cart.test_cases.create!(
  title: 'TC-CART-001: Add Item to Cart',
  preconditions: 'User is logged in. Product exists and is available.',
  steps: "1. Navigate to a product page.\n2. Click 'Add to Cart' button.",
  expected_result: 'Product is added to the shopping cart. Cart quantity indicator updates. Confirmation message may be shown.',
  cypress_id: 'TC-CART-001'
)
puts "Test Cases created."

# Nu creăm Test Runs sau TestRunCases în seeds, acestea sunt dinamice.

puts "Seed data created successfully!"