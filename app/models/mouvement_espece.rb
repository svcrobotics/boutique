# app/models/mouvement_espece.rb
class MouvementEspece < ApplicationRecord
  validates :sens, inclusion: { in: %w[entrée sortie] }
  validates :motif, presence: true
  validates :montant, numericality: { greater_than: 0 }
  validates :date, presence: true
end
