FactoryBot.define do
  factory :test_suite do
    sequence(:name) { |n| "Test Suite #{n}" }
    description { "Test suite description" }
    project
  end
end
