class Vente < ApplicationRecord
  belongs_to :client, optional: true

  belongs_to :versement, optional: true

  has_one :avoir, dependent: :destroy

  has_many :ventes_produits, dependent: :destroy
  has_many :produits, through: :ventes_produits

  #has_many :paiements_ventes
  #has_many :paiements, through: :paiements_ventes

  has_and_belongs_to_many :versements


  accepts_nested_attributes_for :ventes_produits, allow_destroy: true

  before_save :calculer_total
  #validates :mode_paiement, presence: true

  validates :motif_annulation, presence: true, if: :annulee?


  after_commit :mettre_a_jour_produits_vendus

  # L’avoir utilisé pour payer cette vente (utilise: true, vente_id: self.id)
  def avoir_utilise
    Avoir.find_by(vente_id: id, utilise: true)
  end

  # L’avoir émis par cette vente (ex : reste d’un avoir utilisé qui dépasse le montant)
  def avoir_emis
    Avoir.where(vente_id: id, utilise: false)
         .where("remarques LIKE ?", "%Solde restant%").first
  end

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

  def total_remises
    ventes_produits.sum(&:remise)
  end

  def cb
    super || 0
  end

  def amex
    super || 0
  end

  def espece
    super || 0
  end

  def cheque
    super || 0
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
