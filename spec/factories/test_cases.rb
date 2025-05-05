FactoryBot.define do
  factory :test_case do
    title { "MyString" }
    preconditions { "MyText" }
    steps { "MyText" }
    expected_result { "MyText" }
    test_suite { nil }
  end
end
