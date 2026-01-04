class CreateTestCaseTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :test_case_templates do |t|
      t.string :name
      t.text :description
      t.text :preconditions
      t.text :steps
      t.text :expected_result
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
