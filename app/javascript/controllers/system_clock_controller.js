import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="system-clock"
export default class extends Controller {
  static targets = ["display"]

  connect() {
    this.updateTime()
    this.startClock()
  }

  disconnect() {
    this.stopClock()
  }

  startClock() {
    // Update every second
    this.intervalId = setInterval(() => {
      this.updateTime()
    }, 1000)
  }

  stopClock() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
    }
  }

  updateTime() {
    const now = new Date()
    const formattedTime = this.formatTime(now)
    this.displayTarget.textContent = `SYSTEM TIME: ${formattedTime}`
  }

  formatTime(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')

    return `${year}.${month}.${day} ${hours}:${minutes}:${seconds}`
  }
}
