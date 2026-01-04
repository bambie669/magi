FactoryBot.define do
  factory :api_token do
    sequence(:name) { |n| "API Token #{n}" }
    user
    expires_at { nil }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :expiring_soon do
      expires_at { 1.hour.from_now }
    end

    trait :long_lived do
      expires_at { 1.year.from_now }
    end
  end
end
