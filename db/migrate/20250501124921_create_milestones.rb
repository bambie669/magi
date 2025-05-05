class CreateMilestones < ActiveRecord::Migration[7.1]
  def change
    create_table :milestones do |t|
      t.string :name
      t.date :due_date
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
