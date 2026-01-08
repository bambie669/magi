class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  # Notification types
  TYPES = %w[
    test_run_completed
    test_case_failed
    test_run_assigned
    mention
    system_alert
  ].freeze

  validates :notification_type, presence: true, inclusion: { in: TYPES }
  validates :message, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(20) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  # Notification type labels
  def type_label
    case notification_type
    when 'test_run_completed' then 'Test Run Complete'
    when 'test_case_failed' then 'Test Failed'
    when 'test_run_assigned' then 'Test Run Assigned'
    when 'mention' then 'Mention'
    when 'system_alert' then 'System Alert'
    else 'Notification'
    end
  end

  def type_class
    case notification_type
    when 'test_run_completed' then 'text-status-success'
    when 'test_case_failed' then 'text-status-error'
    when 'test_run_assigned' then 'text-primary'
    when 'mention' then 'text-status-warning'
    when 'system_alert' then 'text-status-warning'
    else 'text-text-muted'
    end
  end
end
