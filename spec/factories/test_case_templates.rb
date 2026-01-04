FactoryBot.define do
  factory :test_case_template do
    sequence(:name) { |n| "Template #{n}" }
    description { Faker::Lorem.sentence }
    preconditions { Faker::Lorem.paragraph }
    steps { "1. #{Faker::Lorem.sentence}\n2. #{Faker::Lorem.sentence}\n3. #{Faker::Lorem.sentence}" }
    expected_result { Faker::Lorem.paragraph }
    project
    user
  end
end
