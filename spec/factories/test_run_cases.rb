FactoryBot.define do
  factory :test_run_case do
    test_run
    test_case
    user { nil }
    status { :untested }
    comments { nil }

    trait :passed do
      status { :passed }
    end

    trait :failed do
      status { :failed }
      comments { "Test failed due to assertion error" }
    end

    trait :blocked do
      status { :blocked }
      comments { "Test blocked by environment issue" }
    end
  end
end
