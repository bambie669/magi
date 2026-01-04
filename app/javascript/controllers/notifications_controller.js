import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Notifications Controller
// Manages notification dropdown and real-time updates via ActionCable
export default class extends Controller {
  static targets = ["dropdown", "badge", "list", "emptyState"]
  static values = { userId: Number }

  connect() {
    this.isOpen = false
    this.setupActionCable()
    this.loadNotifications()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }

  setupActionCable() {
    if (!this.hasUserIdValue) return

    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "NotificationsChannel", user_id: this.userIdValue },
      {
        connected: () => console.log("Connected to NotificationsChannel"),
        disconnected: () => console.log("Disconnected from NotificationsChannel"),
        received: (data) => this.handleNewNotification(data)
      }
    )
  }

  toggle() {
    this.isOpen = !this.isOpen
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle('hidden', !this.isOpen)
    }
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.isOpen = false
      if (this.hasDropdownTarget) {
        this.dropdownTarget.classList.add('hidden')
      }
    }
  }

  async loadNotifications() {
    try {
      const response = await fetch('/notifications.json')
      if (response.ok) {
        const data = await response.json()
        this.updateBadge(data.unread_count)
        this.renderNotifications(data.notifications)
      }
    } catch (error) {
      console.error('Failed to load notifications:', error)
    }
  }

  handleNewNotification(data) {
    this.updateBadge(data.unread_count)
    this.prependNotification(data.notification)
    this.showToast(data.notification)
  }

  updateBadge(count) {
    if (this.hasBadgeTarget) {
      if (count > 0) {
        this.badgeTarget.textContent = count > 99 ? '99+' : count
        this.badgeTarget.classList.remove('hidden')
      } else {
        this.badgeTarget.classList.add('hidden')
      }
    }
  }

  renderNotifications(notifications) {
    if (!this.hasListTarget) return

    if (notifications.length === 0) {
      if (this.hasEmptyStateTarget) {
        this.emptyStateTarget.classList.remove('hidden')
      }
      this.listTarget.innerHTML = ''
      return
    }

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.add('hidden')
    }

    this.listTarget.innerHTML = notifications.slice(0, 5).map(n => this.notificationHTML(n)).join('')
  }

  prependNotification(notification) {
    if (!this.hasListTarget) return

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.add('hidden')
    }

    const html = this.notificationHTML(notification)
    this.listTarget.insertAdjacentHTML('afterbegin', html)

    // Keep only last 5 notifications in dropdown
    const items = this.listTarget.querySelectorAll('.notification-item')
    if (items.length > 5) {
      items[items.length - 1].remove()
    }
  }

  notificationHTML(n) {
    return `
      <div class="notification-item p-3 hover:bg-nerv-purple-mid/50 transition-colors border-b border-terminal-red/10 ${n.read ? 'opacity-60' : ''}">
        <div class="flex items-start space-x-3">
          <span class="block w-2 h-2 mt-1.5 rounded-full ${n.read ? 'bg-terminal-gray' : 'bg-terminal-cyan animate-pulse'}"></span>
          <div class="flex-1 min-w-0">
            <span class="text-[10px] font-mono uppercase tracking-wider ${n.type_class}">${n.type_label}</span>
            <p class="text-xs font-mono text-terminal-white/90 mt-1 truncate">${n.message}</p>
          </div>
        </div>
      </div>
    `
  }

  showToast(notification) {
    const toast = document.createElement('div')
    toast.className = `fixed bottom-4 right-4 px-4 py-3 font-mono text-xs uppercase tracking-wider z-50
      bg-nerv-purple-mid border border-terminal-cyan/30 text-terminal-cyan animate-pulse max-w-sm`
    toast.innerHTML = `
      <div class="flex items-start space-x-3">
        <span class="w-2 h-2 mt-1 rounded-full bg-terminal-cyan animate-pulse flex-shrink-0"></span>
        <div>
          <span class="${notification.type_class}">${notification.type_label}</span>
          <p class="text-terminal-white/90 mt-1">${notification.message}</p>
        </div>
      </div>
    `

    document.body.appendChild(toast)

    setTimeout(() => {
      toast.classList.add('opacity-0', 'transition-opacity')
      setTimeout(() => toast.remove(), 300)
    }, 4000)
  }

  async markAsRead(event) {
    const id = event.currentTarget.dataset.notificationId
    try {
      const response = await fetch(`/notifications/${id}/mark_as_read`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      if (response.ok) {
        const data = await response.json()
        this.updateBadge(data.unread_count)
        const item = document.getElementById(`notification_${id}`)
        if (item) {
          item.classList.add('opacity-60')
        }
      }
    } catch (error) {
      console.error('Failed to mark notification as read:', error)
    }
  }
}
