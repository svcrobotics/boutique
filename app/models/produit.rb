class Produit < ApplicationRecord
  has_one_attached :image
  has_one_attached :facture

  belongs_to :fournisseur, optional: true
  belongs_to :client, optional: true

  CATEGORIES = [ "vêtement", "accessoire", "chaussure", "déco" ].freeze

  validates :categorie, inclusion: { in: CATEGORIES }

  has_many :ventes_produits
  has_many :ventes, through: :ventes_produits

  validates :nom, presence: true
  # validates :prix_achat, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  # validates :prix, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  # validates :prix_deposant, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  # validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Liste des états valides sous forme de strings
  ETATS_VALIDES = [ "neuf", "occasion", "depot_vente" ].freeze

  validates :etat, presence: true, inclusion: { in: ETATS_VALIDES }

  # Vérifie la cohérence entre les différents statuts du produit
  # validate :verifier_coherence_statut

  private

  def verifier_coherence_statut
    if neuf? && (en_depot? || occasion?)
      errors.add(:base, "Un produit ne peut pas être à la fois neuf et d'occasion ou en dépôt-vente")
    elsif en_depot? && (neuf? || occasion?)
      errors.add(:base, "Un produit en dépôt-vente ne peut pas être marqué comme neuf ou d'occasion")
    end
  end
end
