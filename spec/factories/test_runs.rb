FactoryBot.define do
  factory :test_run do
    sequence(:name) { |n| "Test Run #{n}" }
    project
    user
  end
end
