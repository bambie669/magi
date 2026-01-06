import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "newScopeInput", "scopeName", "hint"]

  toggle() {
    const value = this.selectTarget.value
    if (value === "new_scope") {
      this.newScopeInputTarget.classList.remove("hidden")
      this.scopeNameTarget.focus()
      if (this.hasHintTarget) {
        this.hintTarget.classList.add("hidden")
      }
    } else {
      this.newScopeInputTarget.classList.add("hidden")
      this.scopeNameTarget.value = ""
      if (this.hasHintTarget) {
        this.hintTarget.classList.remove("hidden")
      }
    }
  }
}
