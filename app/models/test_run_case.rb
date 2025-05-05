class TestRunCase < ApplicationRecord
  belongs_to :test_run
  belongs_to :test_case
  belongs_to :executor, class_name: 'User', foreign_key: 'user_id', optional: true # Executorul poate lipsi inițial

  # Folosește has_one_attached sau has_many_attached
  has_many_attached :attachments

  enum status: { untested: 0, passed: 1, failed: 2, blocked: 3 }

  validates :status, presence: true
  validates :test_run_id, uniqueness: { scope: :test_case_id, message: "Test Case already included in this Test Run" }

  # Poți adăuga validări condiționale, ex: comentariu obligatoriu dacă e failed/blocked
  # validates :comments, presence: true, if: -> { failed? || blocked? }
end