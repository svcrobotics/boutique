# app/models/paiement.rb
class Paiement < ApplicationRecord
  belongs_to :client
  has_many :paiements_ventes, dependent: :destroy
  has_many :ventes, through: :paiements_ventes

  validates :numero_recu, presence: true, uniqueness: true
  before_validation :generer_numero_recu, on: :create

  def lier_aux_ventes_du_deposant_et_calculer_montant
    ventes_concernées = Vente.includes(ventes_produits: :produit).select do |vente|
      vente.ventes_produits.any? do |vp|
        produit = vp.produit
        produit.en_depot? && produit.client_id == client_id
      end
    end

    total = 0.0

    ventes_concernées.each do |vente|
      next if paiements_ventes.exists?(vente_id: vente.id)

      produits_du_client = vente.ventes_produits.map(&:produit).select do |produit|
        produit.en_depot? && produit.client_id == client_id
      end

      PaiementsVente.create!(paiement: self, vente: vente)
      total += produits_du_client.sum(&:prix_deposant)
    end

    update!(montant: total)
  end


  private

  def generer_numero_recu
    self.numero_recu ||= (Paiement.maximum(:numero_recu) || 0) + 1
  end
end
