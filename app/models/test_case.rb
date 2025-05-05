class TestCase < ApplicationRecord
  belongs_to :test_suite
  has_many :test_run_cases, dependent: :destroy # Când ștergi un TC, se șterg și rezultatele asociate
  has_one :project, through: :test_suite # Acces convenabil la proiect

  validates :title, presence: true
  validates :steps, presence: true
  validates :expected_result, presence: true
end