FactoryBot.define do
  factory :test_case do
    sequence(:title) { |n| "Test Case #{n}" }
    preconditions { "Test preconditions" }
    steps { "Step 1: Do something\nStep 2: Verify result" }
    expected_result { "Expected outcome" }
    test_scope
    cypress_id { nil }

    trait :with_cypress_id do
      sequence(:cypress_id) { |n| "TC-#{n.to_s.rjust(3, '0')}" }
    end
  end
end
