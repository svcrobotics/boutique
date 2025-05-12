class Reassort < ApplicationRecord
  belongs_to :produit

  validates :quantite, :date, :prix_achat, presence: true
  validates :taux_remise, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
end
