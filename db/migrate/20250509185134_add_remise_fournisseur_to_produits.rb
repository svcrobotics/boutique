class AddRemiseFournisseurToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :remise_fournisseur, :boolean
    add_column :produits, :taux_remise_fournisseur, :integer
  end
end
