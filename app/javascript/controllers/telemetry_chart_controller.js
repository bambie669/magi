import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"

// NERV-themed telemetry chart controller
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    labels: Array,
    passed: Array,
    failed: Array,
    blocked: Array
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

    // NERV color palette
    const colors = {
      passed: {
        bg: 'rgba(0, 255, 65, 0.3)',      // terminal-green
        border: 'rgba(0, 255, 65, 1)'
      },
      failed: {
        bg: 'rgba(176, 0, 32, 0.3)',       // terminal-red
        border: 'rgba(176, 0, 32, 1)'
      },
      blocked: {
        bg: 'rgba(255, 159, 10, 0.3)',     // terminal-amber
        border: 'rgba(255, 159, 10, 1)'
      },
      grid: 'rgba(0, 212, 255, 0.1)',      // terminal-cyan
      text: 'rgba(107, 107, 107, 1)'       // terminal-gray
    }

    this.chart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: 'NOMINAL',
            data: this.passedValue,
            backgroundColor: colors.passed.bg,
            borderColor: colors.passed.border,
            borderWidth: 1
          },
          {
            label: 'BREACH',
            data: this.failedValue,
            backgroundColor: colors.failed.bg,
            borderColor: colors.failed.border,
            borderWidth: 1
          },
          {
            label: 'PATTERN BLUE',
            data: this.blockedValue,
            backgroundColor: colors.blocked.bg,
            borderColor: colors.blocked.border,
            borderWidth: 1
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          intersect: false,
          mode: 'index'
        },
        plugins: {
          legend: {
            position: 'top',
            align: 'end',
            labels: {
              color: colors.text,
              font: {
                family: 'monospace',
                size: 10
              },
              boxWidth: 12,
              padding: 15
            }
          },
          tooltip: {
            backgroundColor: 'rgba(10, 0, 16, 0.95)',
            titleColor: 'rgba(0, 212, 255, 1)',
            bodyColor: 'rgba(232, 230, 227, 1)',
            borderColor: 'rgba(0, 212, 255, 0.3)',
            borderWidth: 1,
            titleFont: {
              family: 'monospace',
              size: 11
            },
            bodyFont: {
              family: 'monospace',
              size: 10
            },
            padding: 10,
            displayColors: true,
            callbacks: {
              title: function(context) {
                return 'DATE: ' + context[0].label
              }
            }
          }
        },
        scales: {
          x: {
            stacked: true,
            grid: {
              color: colors.grid,
              drawBorder: false
            },
            ticks: {
              color: colors.text,
              font: {
                family: 'monospace',
                size: 9
              }
            }
          },
          y: {
            stacked: true,
            beginAtZero: true,
            grid: {
              color: colors.grid,
              drawBorder: false
            },
            ticks: {
              color: colors.text,
              font: {
                family: 'monospace',
                size: 9
              },
              stepSize: 1
            }
          }
        }
      }
    })
  }
}
