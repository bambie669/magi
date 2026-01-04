FactoryBot.define do
  factory :milestone do
    sequence(:name) { |n| "Milestone #{n}" }
    due_date { 1.month.from_now.to_date }
    association :project
  end
end
