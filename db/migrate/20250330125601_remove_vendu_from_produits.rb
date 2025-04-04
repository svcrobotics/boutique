class RemoveVenduFromProduits < ActiveRecord::Migration[8.0]
  def change
    remove_column :produits, :vendu, :boolean
  end
end
