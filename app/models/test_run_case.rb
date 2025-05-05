class TestRunCase < ApplicationRecord
  belongs_to :test_run
  belongs_to :test_case
 belongs_to :user, optional: true # User who last updated the status

 has_many_attached :attachments # Add this line for Active Storage

 # Define statuses using enum
 # untested: 0, passed: 1, failed: 2, blocked: 3
 enum status: { untested: 0, passed: 1, failed: 2, blocked: 3 }
 validates :test_run_id, uniqueness: { scope: :test_case_id } # Database index provides stronger guarantee


end