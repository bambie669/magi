class Project < ApplicationRecord
  belongs_to :user # Creatorul proiectului
  has_many :milestones, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  # Relația directă has_many :test_cases, through: :test_suites nu mai funcționează simplu
  # din cauza structurii ierarhice cu TestFolder. Folosim o metodă.
  has_many :test_runs, dependent: :destroy
  has_many :test_case_templates, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def all_project_test_cases
    TestCase.joins(test_scope: :test_suite)
            .where(test_suites: { project_id: id })
            .distinct
  end
end