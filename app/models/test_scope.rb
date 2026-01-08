
class TestScope < ApplicationRecord
  belongs_to :test_suite
  belongs_to :parent, class_name: 'TestScope', foreign_key: 'parent_id', optional: true
  has_many :children, class_name: 'TestScope', foreign_key: 'parent_id', dependent: :destroy
  has_many :test_cases, foreign_key: 'test_scope_id', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:test_suite_id, :parent_id], message: "must be unique within its parent" }

  # Returns the full hierarchical path of this scope (e.g., "Parent / Child / Grandchild")
  def full_path
    ancestors = []
    current = self
    while current
      ancestors.unshift(current.name)
      current = current.parent
    end
    ancestors.join(' / ')
  end
end