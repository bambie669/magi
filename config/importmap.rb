# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Chart.js for telemetry visualization (ESM build with auto-registration)
pin "chart.js/auto", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.1/auto/+esm"

# Sortable.js for drag and drop reordering
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/modular/sortable.esm.js"
