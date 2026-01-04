import { Controller } from "@hotwired/stimulus"

// Theme Toggle Controller
// Switches between dark (NERV) and light (EVA-00) themes
// Syncs with user preferences in the database
export default class extends Controller {
  static targets = ["icon", "label"]

  connect() {
    this.updateIcon()
  }

  async toggle() {
    const body = document.body
    const isDark = body.classList.contains('theme-nerv')
    const newTheme = isDark ? 'light' : 'nerv'

    // Update UI immediately
    if (isDark) {
      body.classList.remove('theme-nerv')
      body.classList.add('theme-light')
    } else {
      body.classList.remove('theme-light')
      body.classList.add('theme-nerv')
    }

    this.updateIcon()

    // Sync with server
    try {
      const response = await fetch('/system_config/update_theme', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: `theme=${newTheme}`
      })

      if (!response.ok) {
        console.error('Failed to save theme preference')
      }
    } catch (error) {
      console.error('Error saving theme:', error)
    }
  }

  updateIcon() {
    if (!this.hasIconTarget) return

    const isDark = document.body.classList.contains('theme-nerv')

    if (isDark) {
      // Show sun icon (to switch to light)
      this.iconTarget.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
      `
      if (this.hasLabelTarget) {
        this.labelTarget.textContent = 'EVA-00'
      }
    } else {
      // Show moon icon (to switch to dark)
      this.iconTarget.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
      `
      if (this.hasLabelTarget) {
        this.labelTarget.textContent = 'EVA-01'
      }
    }
  }
}
