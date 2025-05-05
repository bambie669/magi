class Project < ApplicationRecord
  belongs_to :user # Creatorul proiectului
  has_many :milestones, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  has_many :test_cases, through: :test_suites
  has_many :test_runs, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end