import { Controller } from "@hotwired/stimulus"

// Bulk Actions Controller for test cases
// Enables selecting multiple items and performing batch operations
export default class extends Controller {
  static targets = ["checkbox", "selectAll", "actionBar", "selectedCount", "item"]
  static values = { deleteUrl: String }

  connect() {
    this.updateUI()
  }

  toggleAll() {
    const isChecked = this.selectAllTarget.checked
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = isChecked
      this.toggleItemHighlight(checkbox)
    })
    this.updateUI()
  }

  toggleItem(event) {
    this.toggleItemHighlight(event.target)
    this.updateSelectAllState()
    this.updateUI()
  }

  toggleItemHighlight(checkbox) {
    const row = checkbox.closest('[data-bulk-actions-target="item"]')
    if (row) {
      if (checkbox.checked) {
        row.classList.add('bg-terminal-cyan/5', 'border-l-2', 'border-terminal-cyan')
      } else {
        row.classList.remove('bg-terminal-cyan/5', 'border-l-2', 'border-terminal-cyan')
      }
    }
  }

  updateSelectAllState() {
    const total = this.checkboxTargets.length
    const checked = this.selectedIds().length

    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = total > 0 && checked === total
      this.selectAllTarget.indeterminate = checked > 0 && checked < total
    }
  }

  updateUI() {
    const count = this.selectedIds().length

    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = count
    }

    if (this.hasActionBarTarget) {
      if (count > 0) {
        this.actionBarTarget.classList.remove('hidden')
      } else {
        this.actionBarTarget.classList.add('hidden')
      }
    }
  }

  selectedIds() {
    return this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)
  }

  async deleteSelected(event) {
    event.preventDefault()
    const ids = this.selectedIds()

    if (ids.length === 0) return

    const confirmed = confirm(`TERMINATE ${ids.length} protocol(s)? This action cannot be undone.`)
    if (!confirmed) return

    try {
      const response = await fetch(this.deleteUrlValue, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ ids: ids })
      })

      if (response.ok) {
        // Remove the deleted items from DOM
        ids.forEach(id => {
          const checkbox = this.checkboxTargets.find(cb => cb.value === id)
          if (checkbox) {
            const item = checkbox.closest('[data-bulk-actions-target="item"]')
            if (item) {
              item.remove()
            }
          }
        })

        this.updateUI()

        // Show success message
        this.showNotification(`${ids.length} protocol(s) terminated successfully`)
      } else {
        throw new Error('Delete failed')
      }
    } catch (error) {
      console.error('Bulk delete error:', error)
      this.showNotification('Operation failed. Please try again.', 'error')
    }
  }

  exportSelected(event) {
    event.preventDefault()
    const ids = this.selectedIds()

    if (ids.length === 0) return

    // Create a form and submit it to trigger download
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = event.currentTarget.dataset.exportUrl
    form.style.display = 'none'

    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const csrfInput = document.createElement('input')
    csrfInput.type = 'hidden'
    csrfInput.name = 'authenticity_token'
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)

    // Add selected IDs
    ids.forEach(id => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'ids[]'
      input.value = id
      form.appendChild(input)
    })

    document.body.appendChild(form)
    form.submit()
    document.body.removeChild(form)
  }

  showNotification(message, type = 'success') {
    // Create temporary notification
    const notification = document.createElement('div')
    notification.className = `fixed bottom-4 right-4 px-6 py-3 font-mono text-sm uppercase tracking-wider z-50 animate-pulse
      ${type === 'error' ? 'bg-terminal-red text-white' : 'bg-terminal-green text-black'}`
    notification.textContent = message

    document.body.appendChild(notification)

    setTimeout(() => {
      notification.remove()
    }, 3000)
  }

  clearSelection() {
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
      this.toggleItemHighlight(checkbox)
    })
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = false
    }
    this.updateUI()
  }
}
