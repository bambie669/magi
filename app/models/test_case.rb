class TestCase < ApplicationRecord
  belongs_to :test_scope # Actualizat de la test_folder
  has_many :test_run_cases, dependent: :destroy # Când ștergi un TC, se șterg și rezultatele asociate
  has_one :test_suite, through: :test_scope # Actualizat de la test_folder
  has_one :project, through: :test_suite    # Acces convenabil la proiect

  enum source: { manual: 0, imported: 1, cypress_auto: 2 }

  validates :title, presence: true
  validates :steps, presence: true
  validates :expected_result, presence: true
  validates :test_scope_id, presence: true # Actualizat de la test_folder_id
  validates :ref_id, presence: true, uniqueness: true
  validate :cypress_id_unique_within_test_suite

  before_validation :assign_ref_id, on: :create

  def ref_id=(value)
    super if new_record? || ref_id.blank?
  end

  private

  def assign_ref_id
    return if ref_id.present?
    return unless project

    self.ref_id = project.next_test_case_ref_id
  end

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