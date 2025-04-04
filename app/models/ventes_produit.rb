class VentesProduit < ApplicationRecord
  belongs_to :vente
  belongs_to :produit

  validates :quantite, numericality: { only_integer: true, greater_than: 0 }
  validates :prix_unitaire, numericality: { greater_than_or_equal_to: 0 }
  attr_accessor :code_barre
end
