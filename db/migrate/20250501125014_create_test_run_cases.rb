class CreateTestRunCases < ActiveRecord::Migration[7.1]
  def change
    create_table :test_run_cases do |t|
      t.references :test_run, null: false, foreign_key: true
      t.references :test_case, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.references :user, null: true, foreign_key: true
      t.text :comments

      t.timestamps
    end

    add_index :test_run_cases, [:test_run_id, :test_case_id], unique: true
    add_index :test_run_cases, :status
  end
end
