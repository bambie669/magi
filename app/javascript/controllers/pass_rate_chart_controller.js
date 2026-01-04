import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"

// Pass Rate Trend Line Chart
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    labels: Array,
    rates: Array
  }

  connect() {
    this.initChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  initChart() {
    const ctx = this.canvasTarget.getContext('2d')

    // Filter out null values for cleaner display
    const data = this.ratesValue.map((rate, index) =>
      rate !== null ? { x: this.labelsValue[index], y: rate } : null
    ).filter(d => d !== null)

    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: 'Pass Rate %',
          data: this.ratesValue,
          borderColor: 'rgba(0, 255, 65, 1)',
          backgroundColor: 'rgba(0, 255, 65, 0.1)',
          borderWidth: 2,
          fill: true,
          tension: 0.3,
          pointRadius: 0,
          pointHoverRadius: 4,
          pointHoverBackgroundColor: 'rgba(0, 255, 65, 1)',
          spanGaps: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            backgroundColor: 'rgba(10, 0, 16, 0.95)',
            titleColor: 'rgba(0, 212, 255, 1)',
            bodyColor: 'rgba(232, 230, 227, 1)',
            borderColor: 'rgba(0, 212, 255, 0.3)',
            borderWidth: 1,
            titleFont: { family: 'monospace', size: 10 },
            bodyFont: { family: 'monospace', size: 11 },
            callbacks: {
              label: (context) => context.raw !== null ? `${context.raw}%` : 'No data'
            }
          }
        },
        scales: {
          x: {
            display: true,
            grid: { color: 'rgba(0, 212, 255, 0.1)' },
            ticks: {
              color: 'rgba(107, 107, 107, 1)',
              font: { family: 'monospace', size: 8 },
              maxRotation: 0,
              maxTicksLimit: 10
            }
          },
          y: {
            display: true,
            min: 0,
            max: 100,
            grid: { color: 'rgba(0, 212, 255, 0.1)' },
            ticks: {
              color: 'rgba(107, 107, 107, 1)',
              font: { family: 'monospace', size: 9 },
              callback: (value) => value + '%'
            }
          }
        }
      }
    })
  }
}
