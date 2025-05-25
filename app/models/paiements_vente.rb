class PaiementsVente < ApplicationRecord
  belongs_to :paiement
  belongs_to :vente, class_name: "Caisse::Vente"
end
