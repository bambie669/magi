class Milestone < ApplicationRecord
  belongs_to :project

  validates :name, presence: true
  validates :due_date, presence: true
end