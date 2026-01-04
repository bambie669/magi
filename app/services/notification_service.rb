# Service for creating and broadcasting notifications
class NotificationService
  class << self
    # Notify when a test run is completed
    def test_run_completed(test_run)
      users = users_to_notify_for_test_run(test_run)

      users.each do |user|
        notification = create_notification(
          user: user,
          notifiable: test_run,
          notification_type: 'test_run_completed',
          message: "Operation '#{test_run.name}' completed - #{test_run.completion_percentage}% executed"
        )
        broadcast(user, notification)
      end
    end

    # Notify when a test case fails
    def test_case_failed(test_run_case)
      test_run = test_run_case.test_run
      users = users_to_notify_for_test_run(test_run)

      users.each do |user|
        notification = create_notification(
          user: user,
          notifiable: test_run,
          notification_type: 'test_case_failed',
          message: "BREACH: '#{test_run_case.test_case.title}' failed in operation '#{test_run.name}'"
        )
        broadcast(user, notification)
      end
    end

    # Notify when assigned to a test run
    def test_run_assigned(test_run, assigned_user)
      notification = create_notification(
        user: assigned_user,
        notifiable: test_run,
        notification_type: 'test_run_assigned',
        message: "You have been assigned to operation '#{test_run.name}'"
      )
      broadcast(assigned_user, notification)
    end

    # Notify a user about a mention
    def mention(mentioner, mentioned_user, context)
      notification = create_notification(
        user: mentioned_user,
        notifiable: context,
        notification_type: 'mention',
        message: "#{mentioner.display_name} mentioned you in #{context.class.name.underscore.humanize.downcase}"
      )
      broadcast(mentioned_user, notification)
    end

    # System-wide alert
    def system_alert(users, message, notifiable = nil)
      Array(users).each do |user|
        notification = create_notification(
          user: user,
          notifiable: notifiable || user,
          notification_type: 'system_alert',
          message: message
        )
        broadcast(user, notification)
      end
    end

    private

    def create_notification(user:, notifiable:, notification_type:, message:)
      Notification.create!(
        user: user,
        notifiable: notifiable,
        notification_type: notification_type,
        message: message
      )
    end

    def broadcast(user, notification)
      NotificationsChannel.broadcast_notification(user, notification)
    rescue => e
      Rails.logger.error("Failed to broadcast notification: #{e.message}")
    end

    def users_to_notify_for_test_run(test_run)
      # Notify the test run creator and project owner
      users = [test_run.user, test_run.project.owner].compact.uniq
      users
    end
  end
end
