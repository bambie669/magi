// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Fix for Turbo Drive cache issues with back/forward navigation
// This ensures pages are properly rendered after history navigation
document.addEventListener("turbo:before-cache", () => {
  // Remove any temporary classes or states before caching
  document.querySelectorAll(".animate-pulse").forEach(el => {
    el.classList.remove("animate-pulse")
  })
})

document.addEventListener("turbo:load", () => {
  // Re-apply any necessary animations after page load
  document.querySelectorAll("[data-animate]").forEach(el => {
    el.classList.add("animate-pulse")
  })
})

// Handle popstate (back/forward) navigation to ensure proper rendering
document.addEventListener("turbo:visit", (event) => {
  // If this is a restore visit (back/forward), clear and re-render
  if (event.detail.action === "restore") {
    // Force a proper restoration
    document.body.classList.add("turbo-loading")
  }
})

document.addEventListener("turbo:render", () => {
  document.body.classList.remove("turbo-loading")
})
