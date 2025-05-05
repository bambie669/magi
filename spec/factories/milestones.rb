FactoryBot.define do
  factory :milestone do
    name { "MyString" }
    due_date { "2025-05-01" }
    project { nil }
  end
end
