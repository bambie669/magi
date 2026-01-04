# Cypress Test Data Seeds
# Run with: rails runner db/seeds/cypress.rb

puts "Seeding Cypress test data..."

# Create test user
test_user = User.find_or_create_by!(email: 'cypress@nerv.org') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :tester
end
puts "  Created test user: #{test_user.email}"

# Create admin user
admin_user = User.find_or_create_by!(email: 'commander@nerv.org') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :admin
end
puts "  Created admin user: #{admin_user.email}"

# Create sample project
project = Project.find_or_create_by!(name: 'EVA-01 Activation Protocol', user: admin_user) do |p|
  p.description = 'Critical testing protocol for Unit-01 activation sequence'
end
puts "  Created project: #{project.name}"

# Create test suite
test_suite = TestSuite.find_or_create_by!(name: 'Activation Sequence', project: project) do |ts|
  ts.description = 'Core activation protocols'
end
puts "  Created test suite: #{test_suite.name}"

# Create test scope
test_scope = TestScope.find_or_create_by!(name: 'Pre-Activation Checks', test_suite: test_suite)
puts "  Created test scope: #{test_scope.name}"

# Create test cases
test_cases = [
  { title: 'Verify pilot neural sync', preconditions: 'Pilot in entry plug', steps: '1. Initialize A10 nerve clips\n2. Check sync ratio', expected_result: 'Sync ratio > 40%' },
  { title: 'LCL pressure check', preconditions: 'Entry plug filled with LCL', steps: '1. Monitor pressure gauges\n2. Verify oxygenation levels', expected_result: 'All readings nominal' },
  { title: 'Power cable connection', preconditions: 'EVA in cage', steps: '1. Verify umbilical connection\n2. Test power flow', expected_result: 'Power transfer stable' },
  { title: 'AT Field calibration', preconditions: 'Pilot synchronized', steps: '1. Generate test AT Field\n2. Measure field strength', expected_result: 'AT Field within parameters' }
]

test_cases.each do |tc_data|
  tc = TestCase.find_or_create_by!(title: tc_data[:title], test_scope: test_scope) do |tc|
    tc.preconditions = tc_data[:preconditions]
    tc.steps = tc_data[:steps]
    tc.expected_result = tc_data[:expected_result]
  end
  puts "  Created test case: #{tc.title}"
end

# Create a test run
test_run = TestRun.find_or_create_by!(name: 'Initial Activation Test', project: project, user: admin_user)
puts "  Created test run: #{test_run.name}"

# Create test run cases with various statuses
TestCase.where(test_scope: test_scope).each_with_index do |tc, index|
  status = case index
           when 0 then :passed
           when 1 then :passed
           when 2 then :failed
           else :untested
           end

  trc = TestRunCase.find_or_create_by!(test_run: test_run, test_case: tc) do |t|
    t.status = status
    t.comments = status == :failed ? 'Power fluctuation detected' : nil
  end
  puts "  Created test run case: #{tc.title} - #{status}"
end

puts "Cypress test data seeding complete!"
