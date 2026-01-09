class Project < ApplicationRecord
  belongs_to :user # Creatorul proiectului
  has_many :milestones, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  # Relația directă has_many :test_cases, through: :test_suites nu mai funcționează simplu
  # din cauza structurii ierarhice cu TestFolder. Folosim o metodă.
  has_many :test_runs, dependent: :destroy
  has_many :test_case_templates, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :key, presence: true, uniqueness: true,
            format: { with: /\A[A-Z][A-Z0-9]{1,5}\z/, message: "must be 2-6 characters starting with a letter (uppercase letters and numbers only)" }

  before_validation :generate_key, on: :create

  def all_project_test_cases
    TestCase.joins(test_scope: :test_suite)
            .where(test_suites: { project_id: id })
            .distinct
  end

  def next_test_case_ref_id
    with_lock do
      increment!(:test_case_sequence)
      "#{key}-#{test_case_sequence.to_s.rjust(5, '0')}"
    end
  end

  private

  def generate_key
    return if key.present?

    base = name.to_s.gsub(/[^A-Za-z]/, '').upcase[0..5]
    base = base.ljust(2, 'X') if base.length < 2

    candidate = base[0..3]
    counter = 0
    while Project.exists?(key: candidate)
      counter += 1
      candidate = "#{base[0..2]}#{counter}"
    end
    self.key = candidate
  end
end