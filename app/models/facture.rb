class Facture < ApplicationRecord
  belongs_to :fournisseur
  has_many_attached :fichier # Permet de stocker le fichier PDF de la facture

  validates :numero, presence: true, uniqueness: true
  validates :date, presence: true
  validates :montant, numericality: { greater_than: 0 }
end
