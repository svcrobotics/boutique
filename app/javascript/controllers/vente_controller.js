import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["produits", "total"]

  connect() {
    console.log("Vente controller connecté");
    this.calculerTotal()
  }

  ajouterProduit() {
    const time = new Date().getTime();
    const template = document.querySelector("#template-produit").innerHTML.replace(/NEW_RECORD/g, time);
    this.produitsTarget.insertAdjacentHTML("beforeend", template);
  }
  

  supprimerProduit(e) {
    e.target.closest(".produit-fields").remove()
    this.calculerTotal()
  }

  chargerProduit(e) {
    const codeBarre = e.target.value
    const produitFields = e.target.closest(".produit-fields")
    const prixField = produitFields.querySelector("[name*='[prix_unitaire]']")
  
    fetch(`/produits.json?code_barre=${encodeURIComponent(codeBarre)}`)
      .then(response => {
        if (!response.ok) throw new Error("Produit non trouvé")
        return response.json()
      })
      .then(data => {
        if (data.prix) {
          prixField.value = data.prix
          this.calculerTotal()
        } else {
          alert("Prix non disponible pour ce produit.")
        }
      })
      .catch((error) => {
        alert(error.message)
        prixField.value = ""
        this.calculerTotal()
      })
  }
  
  

  calculerTotal() {
    let total = 0
    this.produitsTarget.querySelectorAll(".produit-fields").forEach((el) => {
      const quantite = el.querySelector("[name*='[quantite]']").value || 0
      const prix = el.querySelector("[name*='[prix_unitaire]']").value || 0
      total += parseFloat(quantite) * parseFloat(prix)
    })
    this.totalTarget.textContent = `${total.toFixed(2)} €`
  }
}
