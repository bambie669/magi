
class TestFolder < ApplicationRecord
    belongs_to :test_suite
    belongs_to :parent, class_name: 'TestScope', foreign_key: 'parent_id', optional: true
    has_many :children, class_name: 'TestScope', foreign_key: 'parent_id', dependent: :destroy
    has_many :test_cases, foreign_key: 'test_folder_id', dependent: :destroy
  
    validates :name, presence: true
    # Asigură unicitatea numelui folderului în cadrul părintelui său (sau la rădăcina suitei)
    validates :name, uniqueness: { scope: [:test_suite_id, :parent_id], message: "Folder name must be unique within its parent folder or at the root of the suite." }
  
    # Metodă pentru a obține toate test case-urile dintr-un folder și subfolderele sale
    def all_test_cases_recursive
      cases = self.test_cases.to_a
      # Folosim includes pentru a evita problemele N+1 la încărcarea test_cases pentru copii
      children.includes(:test_cases).each do |child_folder|
        cases.concat(child_folder.all_test_cases_recursive)
      end
      cases
    end
  end