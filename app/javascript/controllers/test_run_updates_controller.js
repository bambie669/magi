import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// TestRunUpdates Controller
// Subscribes to ActionCable for real-time test run status updates
export default class extends Controller {
  static targets = ["passedCount", "failedCount", "blockedCount", "untestedCount", "progressBar", "progressText"]
  static values = { testRunId: Number }

  connect() {
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "TestRunChannel", test_run_id: this.testRunIdValue },
      {
        connected: () => {
          console.log("Connected to TestRunChannel")
        },
        disconnected: () => {
          console.log("Disconnected from TestRunChannel")
        },
        received: (data) => {
          this.handleUpdate(data)
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }

  handleUpdate(data) {
    if (data.type === 'status_update') {
      this.updateCounts(data)
      this.updateTestCaseRow(data)
      this.showUpdateNotification(data)
    }
  }

  updateCounts(data) {
    if (this.hasPassedCountTarget) {
      this.passedCountTarget.textContent = data.passed_count
    }
    if (this.hasFailedCountTarget) {
      this.failedCountTarget.textContent = data.failed_count
    }
    if (this.hasBlockedCountTarget) {
      this.blockedCountTarget.textContent = data.blocked_count
    }
    if (this.hasUntestedCountTarget) {
      this.untestedCountTarget.textContent = data.untested_count
    }
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${data.completion_percentage}%`
    }
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `${data.completion_percentage}%`
    }
  }

  updateTestCaseRow(data) {
    const row = document.getElementById(`test_run_case_${data.test_run_case_id}`)
    if (!row) return

    // Update status indicator
    const statusConfig = this.getStatusConfig(data.status)

    // Update the status dot
    const dot = row.querySelector('.rounded-full')
    if (dot) {
      dot.className = `w-3 h-3 rounded-full ${statusConfig.dot}`
    }

    // Update the status badge
    const badge = row.querySelector('[class*="border-current"]')
    if (badge) {
      badge.className = `${statusConfig.bg} ${statusConfig.text} border border-current/30 px-2 py-1 text-[10px] font-mono uppercase tracking-wider`
      badge.textContent = statusConfig.label
    }

    // Update border
    row.className = row.className.replace(/border-l-2 border-terminal-\w+/g, statusConfig.border)

    // Add pulse effect
    row.classList.add('animate-pulse')
    setTimeout(() => row.classList.remove('animate-pulse'), 2000)
  }

  getStatusConfig(status) {
    const configs = {
      passed: {
        bg: 'bg-terminal-green/10',
        text: 'text-terminal-green',
        border: 'border-l-2 border-terminal-green',
        dot: 'bg-terminal-green animate-pulse',
        label: 'NOMINAL'
      },
      failed: {
        bg: 'bg-terminal-red/10',
        text: 'text-terminal-red',
        border: 'border-l-2 border-terminal-red',
        dot: 'bg-terminal-red animate-pulse',
        label: 'BREACH'
      },
      blocked: {
        bg: 'bg-terminal-amber/10',
        text: 'text-terminal-amber',
        border: 'border-l-2 border-terminal-amber',
        dot: 'bg-terminal-amber',
        label: 'PATTERN BLUE'
      },
      untested: {
        bg: 'bg-nerv-purple-mid',
        text: 'text-terminal-gray',
        border: 'border-l-2 border-terminal-gray-dark',
        dot: 'bg-terminal-gray',
        label: 'STANDBY'
      }
    }
    return configs[status] || configs.untested
  }

  showUpdateNotification(data) {
    const statusLabel = this.getStatusConfig(data.status).label
    const notification = document.createElement('div')
    notification.className = `fixed bottom-4 right-4 px-4 py-3 font-mono text-xs uppercase tracking-wider z-50
      bg-nerv-purple-mid border border-terminal-cyan/30 text-terminal-cyan animate-pulse`
    notification.innerHTML = `
      <div class="flex items-center space-x-3">
        <span class="w-2 h-2 rounded-full ${this.getStatusConfig(data.status).dot}"></span>
        <span>Protocol updated: ${statusLabel}</span>
      </div>
    `

    document.body.appendChild(notification)

    setTimeout(() => {
      notification.classList.add('opacity-0', 'transition-opacity')
      setTimeout(() => notification.remove(), 300)
    }, 3000)
  }
}
