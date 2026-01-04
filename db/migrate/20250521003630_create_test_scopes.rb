class CreateTestScopes < ActiveRecord::Migration[7.1] # Sau versiunea ta de Rails
  def change
    create_table :test_scopes do |t|
      t.string :name, null: false
      t.references :test_suite, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :test_scopes }, null: true # Permite null pentru scope-urile rădăcină, referă aceeași tabelă

      t.timestamps
    end
    # Index pentru a asigura unicitatea numelui folderului în contextul părintelui său și al suitei
    add_index :test_scopes, [:test_suite_id, :parent_id, :name], unique: true, name: 'index_test_scopes_on_suite_parent_name'
  end
end