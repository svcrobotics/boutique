class ChangeDefaultForRemiseFournisseurInProduits < ActiveRecord::Migration[8.0]
  def change
    change_column_default :produits, :remise_fournisseur, from: nil, to: false
  end
end
