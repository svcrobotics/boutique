class ProduitsVersement < ApplicationRecord
  belongs_to :produit
  belongs_to :versement
end
