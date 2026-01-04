class TestCase < ApplicationRecord
  belongs_to :test_scope # Actualizat de la test_folder
  has_many :test_run_cases, dependent: :destroy # Când ștergi un TC, se șterg și rezultatele asociate
  has_one :test_suite, through: :test_scope # Actualizat de la test_folder
  has_one :project, through: :test_suite    # Acces convenabil la proiect

  validates :title, presence: true
  validates :steps, presence: true
  validates :expected_result, presence: true
  validates :test_scope_id, presence: true # Actualizat de la test_folder_id
  validates :cypress_id, uniqueness: true, allow_blank: true
end