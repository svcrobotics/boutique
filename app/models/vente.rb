class Vente < ApplicationRecord
  belongs_to :client, optional: true

  belongs_to :versement, optional: true

  has_many :ventes_produits, dependent: :destroy
  has_many :produits, through: :ventes_produits

  has_many :paiements_ventes
  has_many :paiements, through: :paiements_ventes

  has_and_belongs_to_many :versements


  accepts_nested_attributes_for :ventes_produits, allow_destroy: true

  before_save :calculer_total
  validates :mode_paiement, presence: true

  after_commit :mettre_a_jour_produits_vendus

  def paiement
    paiements.first
  end

  # models/vente.rb
  def clients_deposants
    produits.map(&:client).uniq
  end

  def versement_effectue?
    versements.exists?
  end

  def total_ttc
    ventes_produits.sum { |vp| vp.quantite * vp.prix_unitaire }
  end

  private

  def calculer_total
    self.total = ventes_produits.sum { |vp| vp.quantite * vp.prix_unitaire }
  end

  def mettre_a_jour_produits_vendus
    produits.each do |produit|
      if produit.en_depot?
        produit.update(vendu: true)
      end
    end
  end
end
