FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "Project description" }
    user
  end
end
