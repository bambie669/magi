import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Sortable Controller for drag and drop reordering
// Enables reordering items and persisting the new order via AJAX
export default class extends Controller {
  static targets = ["item"]
  static values = {
    url: String,
    handle: { type: String, default: ".drag-handle" },
    group: String
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: this.handleValue,
      ghostClass: 'sortable-ghost',
      chosenClass: 'sortable-chosen',
      dragClass: 'sortable-drag',
      group: this.hasGroupValue ? this.groupValue : undefined,
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  async onEnd(event) {
    if (event.oldIndex === event.newIndex) return

    const itemId = event.item.dataset.sortableId
    const newPosition = event.newIndex + 1

    // Visual feedback
    event.item.classList.add('sortable-saving')

    try {
      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          id: itemId,
          position: newPosition
        })
      })

      if (response.ok) {
        this.showNotification('Order updated', 'success')
      } else {
        throw new Error('Failed to save order')
      }
    } catch (error) {
      console.error('Sort error:', error)
      this.showNotification('Failed to save order', 'error')
      // Revert the change
      this.sortable.sort(this.sortable.toArray())
    } finally {
      event.item.classList.remove('sortable-saving')
    }
  }

  showNotification(message, type = 'success') {
    const notification = document.createElement('div')
    notification.className = `fixed bottom-4 right-4 px-4 py-2 font-mono text-xs uppercase tracking-wider z-50
      ${type === 'error' ? 'bg-terminal-red text-white' : 'bg-terminal-green/20 border border-terminal-green text-terminal-green'}`
    notification.textContent = message

    document.body.appendChild(notification)

    setTimeout(() => {
      notification.remove()
    }, 2000)
  }
}
