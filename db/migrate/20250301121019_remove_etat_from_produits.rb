class RemoveEtatFromProduits < ActiveRecord::Migration[8.0]
  def change
    remove_column :produits, :etat, :integer
  end
end
