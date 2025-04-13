class Versement < ApplicationRecord
  belongs_to :client

  has_and_belongs_to_many :ventes
  
  has_many :produits_versements
  has_many :produits, through: :produits_versements
end
