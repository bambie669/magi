class ChangeDefaultThemeToDark < ActiveRecord::Migration[7.1]
  def up
    # Update existing users with 'nerv' theme to 'dark'
    execute "UPDATE users SET theme = 'dark' WHERE theme = 'nerv'"

    # Change the default value
    change_column_default :users, :theme, 'dark'
  end

  def down
    # Revert the default value
    change_column_default :users, :theme, 'nerv'

    # Update users back to 'nerv'
    execute "UPDATE users SET theme = 'nerv' WHERE theme = 'dark'"
  end
end
