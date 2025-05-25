# app/models/paiement.rb
class Paiement < ApplicationRecord
  belongs_to :client
  has_many :paiements_ventes
  has_many :ventes, class_name: "Caisse::Vente", through: :paiements_ventes

  validates :numero_recu, presence: true, uniqueness: true
  before_validation :generer_numero_recu, on: :create
  after_create :lier_aux_ventes_du_deposant_et_calculer_montant

  def lier_aux_ventes_du_deposant_et_calculer_montant
    total = 0.0

    client.produits.each do |produit|
      next unless produit.en_depot? && produit.vendu?

      produit.ventes.each do |vente|
        next if PaiementsVente.exists?(paiement: self, vente: vente)

        PaiementsVente.create!(paiement: self, vente: vente)
        total += produit.prix_deposant
      end
    end

    update!(montant: total)
  end

  def produits_payes
    produits_quantites = Hash.new(0)

    ventes.each do |vente|
      vente.ventes_produits.each do |vp|
        produit = vp.produit
        next unless produit.en_depot? && produit.vendu? && produit.client == client

        produits_quantites[produit] += vp.quantite
      end
    end

    produits_quantites
  end


  private

  def generer_numero_recu
    self.numero_recu ||= (Paiement.maximum(:numero_recu) || 0) + 1
  end
end
