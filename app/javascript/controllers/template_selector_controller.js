import { Controller } from "@hotwired/stimulus"

// Template Selector Controller
// Allows selecting a template and applying its values to form fields
export default class extends Controller {
  static targets = ["select", "title", "preconditions", "steps", "expectedResult"]
  static values = { applyUrl: String }

  async apply() {
    const templateId = this.selectTarget.value
    if (!templateId) return

    try {
      const response = await fetch(this.applyUrlValue.replace(':id', templateId))
      if (response.ok) {
        const data = await response.json()
        this.fillForm(data)
        this.showNotification('Template applied successfully')
      } else {
        this.showNotification('Failed to apply template', 'error')
      }
    } catch (error) {
      console.error('Template apply error:', error)
      this.showNotification('Failed to apply template', 'error')
    }
  }

  fillForm(data) {
    if (this.hasTitleTarget && data.title) {
      this.titleTarget.value = data.title
    }
    if (this.hasPreconditionsTarget && data.preconditions) {
      this.preconditionsTarget.value = data.preconditions
    }
    if (this.hasStepsTarget && data.steps) {
      this.stepsTarget.value = data.steps
    }
    if (this.hasExpectedResultTarget && data.expected_result) {
      this.expectedResultTarget.value = data.expected_result
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
