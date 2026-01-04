class CreateTestCases < ActiveRecord::Migration[7.1]
  def change
    create_table :test_cases do |t|
      t.string :title, null: false
      t.text :preconditions
      t.text :steps
      t.text :expected_result
      t.references :test_suite, null: false, foreign_key: true

      t.timestamps
    end
  end
end