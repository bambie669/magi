
class TestScope < ApplicationRecord
    belongs_to :test_suite
    belongs_to :parent, class_name: 'TestScope', foreign_key: 'parent_id', optional: true # Asoc. auto-referențială
    has_many :children, class_name: 'TestScope', foreign_key: 'parent_id', dependent: :destroy # Asoc. auto-referențială
    has_many :test_cases, foreign_key: 'test_scope_id', dependent: :destroy # Va folosi coloana test_scope_id din tabelul test_cases
  
    validates :name, presence: true
    # Asigură unicitatea numelui folderului în cadrul părintelui său (sau la rădăcina suitei)
    validates :name, uniqueness: { scope: [:test_suite_id, :parent_id], message: "Folder name must be unique within its parent folder or at the root of the suite." }
  
    # Metodă pentru a obține toate test case-urile dintr-un folder și subfolderele sale
    # în mod recursiv.
    def all_test_cases_recursive
      cases = self.test_cases.to_a
      # Folosim includes pentru a evita problemele N+1 la încărcarea test_cases pentru copii
      children.includes(:test_cases).each do |child_scope| # Am redenumit child_folder în child_scope
        cases.concat(child_scope.all_test_cases_recursive)
      end
      cases
    end

    # Metodă pentru a obține toate scope-urile descendente
    # Poate fi optimizată pentru performanță pe ierarhii adânci.
    def all_descendant_scopes
      descendants = []
      children.each do |child_scope|
        descendants << child_scope
        descendants.concat(child_scope.all_descendant_scopes)
      end
      descendants
    end
  end