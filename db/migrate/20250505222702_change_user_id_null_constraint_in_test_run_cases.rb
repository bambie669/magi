class ChangeUserIdNullConstraintInTestRunCases < ActiveRecord::Migration[7.1]
  def change
    # Explicitly allow NULL values for the user_id column
    # The third argument 'true' means allow null.
    change_column_null :test_run_cases, :user_id, true
  end
end