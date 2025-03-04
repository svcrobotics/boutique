class Vente < ApplicationRecord
  belongs_to :client
  has_many :ventes_produits, dependent: :destroy
  has_many :produits, through: :ventes_produits

  validates :mode_paiement, presence: true
end
