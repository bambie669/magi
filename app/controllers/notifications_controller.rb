class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :mark_as_read]

  # GET /notifications
  def index
    notifications = current_user.notifications.recent.includes(:notifiable)
    @pagy, @notifications = pagy(notifications, items: 20)
    @unread_count = current_user.unread_notifications_count

    respond_to do |format|
      format.html
      format.json { render json: { notifications: @notifications.map { |n| notification_json(n) }, unread_count: @unread_count } }
    end
  end

  # POST /notifications/:id/mark_as_read
  def mark_as_read
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back fallback_location: notifications_path }
      format.json { render json: { success: true, unread_count: current_user.unread_notifications_count } }
    end
  end

  # POST /notifications/mark_all_as_read
  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'All notifications marked as read.' }
      format.json { render json: { success: true, unread_count: 0 } }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def notification_json(notification)
    {
      id: notification.id,
      type: notification.notification_type,
      type_label: notification.type_label,
      type_class: notification.type_class,
      message: notification.message,
      read: notification.read?,
      created_at: notification.created_at.iso8601,
      notifiable_type: notification.notifiable_type,
      notifiable_id: notification.notifiable_id
    }
  end
end
