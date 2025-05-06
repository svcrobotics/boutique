class AddRemiseToVentesProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :ventes_produits, :remise, :decimal
  end
end
