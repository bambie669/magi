class AddCypressIdToTestCases < ActiveRecord::Migration[7.1]
  def change
    add_column :test_cases, :cypress_id, :string
    add_index :test_cases, :cypress_id, unique: true
  end
end
