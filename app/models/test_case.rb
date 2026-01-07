class TestCase < ApplicationRecord
  belongs_to :test_scope # Actualizat de la test_folder
  has_many :test_run_cases, dependent: :destroy # Când ștergi un TC, se șterg și rezultatele asociate
  has_one :test_suite, through: :test_scope # Actualizat de la test_folder
  has_one :project, through: :test_suite    # Acces convenabil la proiect

  validates :title, presence: true
  validates :steps, presence: true
  validates :expected_result, presence: true
  validates :test_scope_id, presence: true # Actualizat de la test_folder_id
  validate :cypress_id_unique_within_test_suite

  private

  def cypress_id_unique_within_test_suite
    return if cypress_id.blank?
    return unless test_scope&.test_suite

    existing = test_scope.test_suite.test_cases
                         .where(cypress_id: cypress_id)
                         .where.not(id: id)
                         .exists?

    errors.add(:cypress_id, "has already been taken in this test suite") if existing
  end
end