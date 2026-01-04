# Channel for real-time notification delivery
# Each user subscribes to their own notification stream
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
  end

  # Class method to broadcast a notification to a specific user
  def self.broadcast_notification(user, notification)
    broadcast_to(user, {
      notification: {
        id: notification.id,
        type: notification.notification_type,
        type_label: notification.type_label,
        type_class: notification.type_class,
        message: notification.message,
        read: notification.read?,
        created_at: notification.created_at.iso8601,
        notifiable_type: notification.notifiable_type,
        notifiable_id: notification.notifiable_id
      },
      unread_count: user.unread_notifications_count
    })
  end
end
