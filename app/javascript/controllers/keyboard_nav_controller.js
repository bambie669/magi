import { Controller } from "@hotwired/stimulus"

// Keyboard Navigation Controller
// Provides vim-style navigation (j/k) through lists
export default class extends Controller {
  static targets = ["item"]
  static values = {
    wrap: { type: Boolean, default: true }
  }

  connect() {
    this.currentIndex = -1
    this.boundKeyHandler = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundKeyHandler)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundKeyHandler)
  }

  handleKeydown(event) {
    // Don't interfere with input fields
    if (this.isInputElement(event.target)) return

    switch (event.key.toLowerCase()) {
      case 'j':
        event.preventDefault()
        this.moveDown()
        break
      case 'k':
        event.preventDefault()
        this.moveUp()
        break
      case 'enter':
        event.preventDefault()
        this.activateCurrent()
        break
      case 'escape':
        this.clearSelection()
        break
    }
  }

  isInputElement(element) {
    const tagName = element.tagName.toLowerCase()
    return tagName === 'input' || tagName === 'textarea' || tagName === 'select' || element.isContentEditable
  }

  moveDown() {
    const items = this.itemTargets
    if (items.length === 0) return

    this.currentIndex++
    if (this.currentIndex >= items.length) {
      this.currentIndex = this.wrapValue ? 0 : items.length - 1
    }
    this.updateSelection()
  }

  moveUp() {
    const items = this.itemTargets
    if (items.length === 0) return

    this.currentIndex--
    if (this.currentIndex < 0) {
      this.currentIndex = this.wrapValue ? items.length - 1 : 0
    }
    this.updateSelection()
  }

  updateSelection() {
    const items = this.itemTargets
    items.forEach((item, index) => {
      if (index === this.currentIndex) {
        item.classList.add('keyboard-selected')
        item.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
      } else {
        item.classList.remove('keyboard-selected')
      }
    })
  }

  activateCurrent() {
    const items = this.itemTargets
    if (this.currentIndex >= 0 && this.currentIndex < items.length) {
      const currentItem = items[this.currentIndex]
      // Find and click a link within the item, or the item itself
      const link = currentItem.querySelector('a') || currentItem.closest('a')
      if (link) {
        link.click()
      } else if (currentItem.tagName.toLowerCase() === 'a') {
        currentItem.click()
      }
    }
  }

  clearSelection() {
    this.currentIndex = -1
    this.itemTargets.forEach(item => {
      item.classList.remove('keyboard-selected')
    })
  }
}
