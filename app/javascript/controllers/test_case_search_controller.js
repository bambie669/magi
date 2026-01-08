import { Controller } from "@hotwired/stimulus"

// Test Case Search Controller
// Provides filtering and selection for test cases in test run creation
export default class extends Controller {
  static targets = ["searchInput", "item", "checkbox", "selectedCount", "visibleCount", "selectAllBtn", "noResults", "list"]

  connect() {
    this.updateCount()
  }

  filter() {
    const query = this.searchInputTarget.value.toLowerCase().trim()
    let visibleCount = 0

    this.itemTargets.forEach(item => {
      const title = item.dataset.title || ""
      const scope = item.dataset.scope || ""
      const matches = query === "" || title.includes(query) || scope.includes(query)

      if (matches) {
        item.classList.remove("hidden")
        visibleCount++
      } else {
        item.classList.add("hidden")
      }
    })

    // Update visible count
    if (this.hasVisibleCountTarget) {
      this.visibleCountTarget.textContent = visibleCount
    }

    // Show/hide no results message
    if (this.hasNoResultsTarget) {
      if (visibleCount === 0 && query !== "") {
        this.noResultsTarget.classList.remove("hidden")
        this.listTarget.classList.add("hidden")
      } else {
        this.noResultsTarget.classList.add("hidden")
        this.listTarget.classList.remove("hidden")
      }
    }

    // Update scope headers visibility
    this.updateScopeHeaders()
  }

  updateScopeHeaders() {
    // Hide scope headers if all their items are hidden
    const scopeGroups = this.listTarget.querySelectorAll(':scope > div.mb-2')
    scopeGroups.forEach(group => {
      const visibleItems = group.querySelectorAll('.test-case-item:not(.hidden)')
      const header = group.querySelector('.sticky')
      if (header) {
        if (visibleItems.length === 0) {
          group.classList.add("hidden")
        } else {
          group.classList.remove("hidden")
        }
      }
    })
  }

  updateCount() {
    const checkedCount = this.checkboxTargets.filter(cb => cb.checked).length
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = checkedCount
    }

    // Update select all button text
    if (this.hasSelectAllBtnTarget) {
      const visibleCheckboxes = this.checkboxTargets.filter(cb => !cb.closest('.test-case-item')?.classList.contains('hidden'))
      const allVisibleChecked = visibleCheckboxes.length > 0 && visibleCheckboxes.every(cb => cb.checked)
      this.selectAllBtnTarget.textContent = allVisibleChecked ? "Deselect All" : "Select All"
    }
  }

  toggleSelectAll() {
    // Only toggle visible items
    const visibleCheckboxes = this.checkboxTargets.filter(cb => !cb.closest('.test-case-item')?.classList.contains('hidden'))
    const allChecked = visibleCheckboxes.every(cb => cb.checked)

    visibleCheckboxes.forEach(cb => {
      cb.checked = !allChecked
    })

    this.updateCount()
  }
}
