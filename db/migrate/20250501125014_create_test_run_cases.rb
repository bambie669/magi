class CreateTestRunCases < ActiveRecord::Migration[7.1]
  def change
    create_table :test_run_cases do |t|
      t.references :test_run, null: false, foreign_key: true
      t.references :test_case, null: false, foreign_key: true
      t.integer :status
      t.references :test_run, null: false, foreign_key: true, index: false # Index handled below
      t.references :test_case, null: false, foreign_key: true
      t.integer :status, default: 0, null: false # Default to 'untested'
      t.references :user, null: true, foreign_key: true # Allow null if status not yet set by a user
      t.index [:test_run_id, :test_case_id], unique: true # Ensure a case is only added once per run




      t.timestamps
    end
  end
end
