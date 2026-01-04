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

  # NERV-style notification labels
  def type_label
    case notification_type
    when 'test_run_completed' then 'OPERATION COMPLETE'
    when 'test_case_failed' then 'BREACH DETECTED'
    when 'test_run_assigned' then 'DEPLOYMENT ORDER'
    when 'mention' then 'DIRECT COMM'
    when 'system_alert' then 'SYSTEM ALERT'
    else 'NOTIFICATION'
    end
  end

  def type_class
    case notification_type
    when 'test_run_completed' then 'text-terminal-green'
    when 'test_case_failed' then 'text-terminal-red'
    when 'test_run_assigned' then 'text-terminal-cyan'
    when 'mention' then 'text-terminal-amber'
    when 'system_alert' then 'text-terminal-amber'
    else 'text-terminal-gray'
    end
  end
end
