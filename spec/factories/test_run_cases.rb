FactoryBot.define do
  factory :test_run_case do
    test_run { nil }
    test_case { nil }
    user { nil }
    status { 1 }
    comments { "MyText" }
  end
end
