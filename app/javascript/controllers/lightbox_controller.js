import { Controller } from "@hotwired/stimulus"

// Lightbox Controller for attachment previews
// Shows full-size images in a modal overlay
export default class extends Controller {
  static targets = ["modal", "image", "caption", "counter"]
  static values = {
    images: Array,
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    // Close on escape key
    this.boundKeyHandler = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundKeyHandler)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundKeyHandler)
  }

  handleKeydown(event) {
    if (!this.hasModalTarget || this.modalTarget.classList.contains('hidden')) return

    switch (event.key) {
      case 'Escape':
        this.close()
        break
      case 'ArrowLeft':
        this.previous()
        break
      case 'ArrowRight':
        this.next()
        break
    }
  }

  open(event) {
    event.preventDefault()

    const url = event.currentTarget.dataset.lightboxUrl
    const caption = event.currentTarget.dataset.lightboxCaption || ''
    const index = parseInt(event.currentTarget.dataset.lightboxIndex || '0')

    this.currentIndexValue = index
    this.showImage(url, caption)
    this.modalTarget.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }

  close() {
    this.modalTarget.classList.add('hidden')
    document.body.style.overflow = ''
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  previous() {
    if (this.imagesValue.length === 0) return

    this.currentIndexValue = (this.currentIndexValue - 1 + this.imagesValue.length) % this.imagesValue.length
    const img = this.imagesValue[this.currentIndexValue]
    this.showImage(img.url, img.caption)
  }

  next() {
    if (this.imagesValue.length === 0) return

    this.currentIndexValue = (this.currentIndexValue + 1) % this.imagesValue.length
    const img = this.imagesValue[this.currentIndexValue]
    this.showImage(img.url, img.caption)
  }

  showImage(url, caption) {
    if (this.hasImageTarget) {
      this.imageTarget.src = url
      this.imageTarget.alt = caption
    }
    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = caption
    }
    if (this.hasCounterTarget && this.imagesValue.length > 1) {
      this.counterTarget.textContent = `${this.currentIndexValue + 1} / ${this.imagesValue.length}`
      this.counterTarget.classList.remove('hidden')
    }
  }
}
