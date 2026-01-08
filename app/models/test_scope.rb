
class TestScope < ApplicationRecord
    belongs_to :test_suite
    belongs_to :parent, class_name: 'TestScope', foreign_key: 'parent_id', optional: true # Asoc. auto-referențială
    has_many :children, class_name: 'TestScope', foreign_key: 'parent_id', dependent: :destroy # Asoc. auto-referențială
    has_many :test_cases, foreign_key: 'test_scope_id', dependent: :destroy # Va folosi coloana test_scope_id din tabelul test_cases
  
    validates :name, presence: true
    # Asigură unicitatea numelui folderului în cadrul părintelui său (sau la rădăcina suitei)
    validates :name, uniqueness: { scope: [:test_suite_id, :parent_id], message: "Folder name must be unique within its parent folder or at the root of the suite." }
  end