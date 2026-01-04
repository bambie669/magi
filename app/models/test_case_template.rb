class TestCaseTemplate < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :name, presence: true
  validates :project, presence: true
  validates :user, presence: true

  scope :ordered, -> { order(name: :asc) }

  # Apply this template to create test case attributes
  def to_test_case_attributes
    {
      title: name,
      preconditions: preconditions,
      steps: steps,
      expected_result: expected_result
    }
  end
end
