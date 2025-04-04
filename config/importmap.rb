# Pin Rails libraries
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Pin all controllers automatically (convention)
pin_all_from "app/javascript/controllers", under: "controllers"

# ⛳️ Optional: pin individually if auto-pin ne fonctionne pas bien
pin "controllers/focus_controller", to: "controllers/focus_controller.js"
pin "controllers/vente_controller", to: "controllers/vente_controller.js"
pin "controllers/deposant_controller", to: "controllers/deposant_controller.js"
pin "controllers/hello_controller", to: "controllers/hello_controller.js"
