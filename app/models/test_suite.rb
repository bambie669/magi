class TestSuite < ApplicationRecord
  belongs_to :project
  # All test scopes belonging to this suite
  has_many :test_scopes, dependent: :destroy
  # All test cases through test scopes
  has_many :test_cases, through: :test_scopes
  # TestSuite are scope-uri rădăcină (cele fără parent_id)
  has_many :root_test_scopes, -> { where(parent_id: nil).order(:name) },
           class_name: 'TestScope',
           foreign_key: 'test_suite_id'

  validates :name, presence: true
end