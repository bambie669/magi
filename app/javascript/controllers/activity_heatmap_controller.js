import { Controller } from "@hotwired/stimulus"

// GitHub-style Activity Heatmap
export default class extends Controller {
  static targets = ["container"]
  static values = {
    data: Object
  }

  connect() {
    this.render()
  }

  render() {
    const data = this.dataValue
    const container = this.containerTarget

    // Calculate date range (last 365 days, organized by weeks)
    const today = new Date()
    const startDate = new Date(today)
    startDate.setDate(startDate.getDate() - 364)

    // Adjust to start on Sunday
    const dayOfWeek = startDate.getDay()
    startDate.setDate(startDate.getDate() - dayOfWeek)

    // Calculate max value for color scaling
    const values = Object.values(data)
    const maxValue = Math.max(...values, 1)

    // Create SVG
    const cellSize = 10
    const cellGap = 2
    const weeksToShow = 53
    const width = weeksToShow * (cellSize + cellGap) + 30
    const height = 7 * (cellSize + cellGap) + 20

    let svg = `<svg width="${width}" height="${height}" class="activity-heatmap">`

    // Day labels
    const days = ['', 'M', '', 'W', '', 'F', '']
    days.forEach((day, i) => {
      svg += `<text x="0" y="${i * (cellSize + cellGap) + cellSize + 8}"
              class="text-[8px] fill-terminal-gray font-mono">${day}</text>`
    })

    // Month labels
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    let lastMonth = -1

    // Draw cells
    const currentDate = new Date(startDate)
    for (let week = 0; week < weeksToShow; week++) {
      for (let day = 0; day < 7; day++) {
        if (currentDate > today) break

        const dateStr = currentDate.toISOString().split('T')[0]
        const count = data[dateStr] || 0
        const intensity = count > 0 ? Math.min(Math.ceil((count / maxValue) * 4), 4) : 0

        const x = week * (cellSize + cellGap) + 20
        const y = day * (cellSize + cellGap) + 15

        // Month label
        if (day === 0 && currentDate.getMonth() !== lastMonth) {
          lastMonth = currentDate.getMonth()
          svg += `<text x="${x}" y="10" class="text-[8px] fill-terminal-gray font-mono">${months[lastMonth]}</text>`
        }

        const colors = [
          'rgba(30, 0, 40, 0.8)',      // 0: empty
          'rgba(0, 255, 65, 0.2)',     // 1: low
          'rgba(0, 255, 65, 0.4)',     // 2: medium-low
          'rgba(0, 255, 65, 0.6)',     // 3: medium-high
          'rgba(0, 255, 65, 0.9)'      // 4: high
        ]

        svg += `<rect x="${x}" y="${y}" width="${cellSize}" height="${cellSize}"
                rx="2" fill="${colors[intensity]}"
                class="hover:stroke-terminal-cyan hover:stroke-1 cursor-pointer"
                data-date="${dateStr}" data-count="${count}">
                <title>${dateStr}: ${count} executions</title>
                </rect>`

        currentDate.setDate(currentDate.getDate() + 1)
      }
    }

    svg += '</svg>'

    // Legend
    svg += `
      <div class="flex items-center justify-end mt-2 space-x-1 text-[9px] font-mono text-terminal-gray">
        <span>Less</span>
        <span class="w-2 h-2 rounded-sm" style="background: rgba(30, 0, 40, 0.8)"></span>
        <span class="w-2 h-2 rounded-sm" style="background: rgba(0, 255, 65, 0.2)"></span>
        <span class="w-2 h-2 rounded-sm" style="background: rgba(0, 255, 65, 0.4)"></span>
        <span class="w-2 h-2 rounded-sm" style="background: rgba(0, 255, 65, 0.6)"></span>
        <span class="w-2 h-2 rounded-sm" style="background: rgba(0, 255, 65, 0.9)"></span>
        <span>More</span>
      </div>
    `

    container.innerHTML = svg
  }
}
