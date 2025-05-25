class Avoir < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :vente, class_name: "Caisse::Vente"

  validates :montant, numericality: { greater_than: 0 }
  scope :utilises, -> { where(utilise: true) }
  scope :non_utilises, -> { where(utilise: false) }
end
