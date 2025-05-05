class TestRun < ApplicationRecord
  belongs_to :project
  belongs_to :user # Creatorul test run-ului
  has_many :test_run_cases, dependent: :destroy
  has_many :test_cases, through: :test_run_cases

  validates :name, presence: true

  # Metodă pentru a popula TestRunCases la crearea unui TestRun
  # Poate fi apelată din controller sau callback (atenție la performanță la callback)
  def add_test_cases(test_case_ids)
    test_case_ids.each do |tc_id|
      self.test_run_cases.find_or_create_by(test_case_id: tc_id) do |trc|
        trc.status = :untested # Setează statusul inițial
      end
    end
  end

  # Statistici simple
  def total_cases
    test_run_cases.count
  end

  def passed_cases
    test_run_cases.passed.count
  end

  def failed_cases
    test_run_cases.failed.count
  end

  def blocked_cases
    test_run_cases.blocked.count
  end

  def untested_cases
    test_run_cases.untested.count
  end

  def completion_percentage
    total = total_cases
    return 0 if total.zero?
    completed = total - untested_cases
    (completed.to_f / total * 100).round(1)
  end
end