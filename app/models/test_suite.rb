class TestSuite < ApplicationRecord
  belongs_to :project
  has_many :test_cases, dependent: :destroy

  validates :name, presence: true
end