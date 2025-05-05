class CreateTestRunCases < ActiveRecord::Migration[7.1]
  def change
    create_table :test_run_cases do |t|
      t.references :test_run, null: false, foreign_key: true
      t.references :test_case, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.text :comments

      t.timestamps
    end
  end
end
