class AddKeyAndSequenceToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :key, :string, limit: 6
    add_index :projects, :key, unique: true
    add_column :projects, :test_case_sequence, :integer, default: 0, null: false
  end
end
