class AddRefIdAndSourceToTestCases < ActiveRecord::Migration[7.1]
  def change
    add_column :test_cases, :ref_id, :string
    add_index :test_cases, :ref_id, unique: true
    add_column :test_cases, :source, :integer, default: 0, null: false
    add_column :test_cases, :import_ref, :string
    add_index :test_cases, :import_ref
  end
end
