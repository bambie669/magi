class RemoveUniqueCypressIdIndex < ActiveRecord::Migration[7.1]
  def change
    # Remove the unique index on cypress_id
    remove_index :test_cases, :cypress_id, unique: true

    # Add a regular index for performance (uniqueness is now enforced per test_suite in the model)
    add_index :test_cases, :cypress_id
  end
end
