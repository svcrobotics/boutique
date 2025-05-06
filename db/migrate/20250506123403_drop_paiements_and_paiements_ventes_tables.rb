class DropPaiementsAndPaiementsVentesTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :paiements_ventes
    drop_table :paiements
  end
end
