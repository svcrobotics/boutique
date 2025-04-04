class PaiementsVente < ApplicationRecord
  belongs_to :paiement
  belongs_to :vente
end
