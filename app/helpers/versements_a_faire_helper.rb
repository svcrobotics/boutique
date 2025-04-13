module VersementsAFaireHelper
  def self.call
    lignes_deja_payees = ProduitsVersement.group(:produit_id, :vente_id).sum(:quantite)

    ventes = Vente.includes(ventes_produits: { produit: :client }).order(created_at: :desc)

    paiements_groupes = Hash.new { |h, k| h[k] = [] }

    ventes.each do |vente|
      vente.ventes_produits.each do |vp|
        produit = vp.produit
        client = produit.client
        next unless produit.en_depot? && client.present?

        quantite_vendue = vp.quantite
        quantite_deja_payee = lignes_deja_payees[[ produit.id, vente.id ]] || 0
        quantite_restante = quantite_vendue - quantite_deja_payee
        next if quantite_restante <= 0

        paiements_groupes[client] << {
          produit: produit,
          quantite: quantite_restante,
          prix_unitaire: produit.prix_deposant,
          vente: vente
        }
      end
    end

    paiements_groupes.map do |client, lignes|
      {
        client: client,
        lignes: lignes,
        total: lignes.sum { |l| l[:quantite] * l[:prix_unitaire] }
      }
    end
  end
end
