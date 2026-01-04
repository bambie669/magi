FactoryBot.define do
  factory :notification do
    user
    association :notifiable, factory: :project
    notification_type { "test_run_completed" }
    message { Faker::Lorem.sentence }
    read_at { nil }

    trait :read do
      read_at { Time.current }
    end

    trait :test_case_failed do
      notification_type { "test_case_failed" }
    end

    trait :test_run_assigned do
      notification_type { "test_run_assigned" }
    end

    trait :mention do
      notification_type { "mention" }
    end

    trait :system_alert do
      notification_type { "system_alert" }
    end
  end
end
