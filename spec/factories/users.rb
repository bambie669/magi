FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    role { :tester } # Default role

    trait :admin do
      role { :admin }
    end

    trait :manager do
      role { :manager }
    end
  end
end