// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
// import "./controllers"

//import Rails from "@rails/ujs"
//Rails.start()

document.addEventListener("DOMContentLoaded", () => {
  const scanInput = document.createElement("input")
  scanInput.setAttribute("type", "text")
  scanInput.setAttribute("id", "global-scan-input")
  scanInput.setAttribute("autocomplete", "off")
  scanInput.style.position = "fixed"
  scanInput.style.top = "0"
  scanInput.style.left = "0"
  scanInput.style.opacity = "0"
  scanInput.style.zIndex = "-1"
  document.body.appendChild(scanInput)

  let timeout
  scanInput.addEventListener("input", () => {
    const code = scanInput.value.trim()
    if (code.length > 3) {
      window.location.href = `/ventes/new?code_barre=${encodeURIComponent(code)}`
    }
    scanInput.value = ""
  })

  setInterval(() => {
    // Ne force le focus QUE si aucun élément n'est actuellement en focus
    if (document.activeElement === document.body) {
      scanInput.focus()
    }
  }, 1000)

})
