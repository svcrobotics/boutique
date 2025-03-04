import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="deposant"
export default class extends Controller {
  static targets = ["ancienIdField", "checkbox"]

  connect() {
    this.toggleAncienIdField(); // Vérifier au chargement si le champ doit être affiché
  }

  toggleAncienIdField() {
    if (this.checkboxTarget.checked) {
      this.ancienIdFieldTarget.classList.remove("hidden");
    } else {
      this.ancienIdFieldTarget.classList.add("hidden");
      this.ancienIdFieldTarget.querySelector("input").value = ""; // Efface le champ si caché
    }
  }
}
