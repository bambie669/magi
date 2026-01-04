FactoryBot.define do
  factory :test_scope do
    sequence(:name) { |n| "Test Scope #{n}" }
    test_suite
    parent { nil }

    trait :with_parent do
      parent { association :test_scope }
    end
  end
end
