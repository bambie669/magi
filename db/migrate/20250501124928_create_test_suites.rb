class CreateTestSuites < ActiveRecord::Migration[7.1]
  def change
    create_table :test_suites do |t|
      t.string :name
      t.text :description
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
