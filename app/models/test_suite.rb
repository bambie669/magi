class TestSuite < ApplicationRecord
  belongs_to :project
  # All test scopes belonging to this suite
  has_many :test_scopes, dependent: :destroy
  # TestSuite are scope-uri rădăcină (cele fără parent_id)
  has_many :root_test_scopes, -> { where(parent_id: nil).order(:name) },
           class_name: 'TestScope',
           foreign_key: 'test_suite_id'

  validates :name, presence: true

  # Metodă pentru a obține toate test case-urile dintr-o suită, indiferent de scope.
  # Eager loads test_cases pentru root_scopes pentru a optimiza primul nivel al recursivității.
  def all_test_cases
    self.root_test_scopes.includes(:test_cases).flat_map(&:all_test_cases_recursive) # Actualizat de la root_test_folders
  end
end