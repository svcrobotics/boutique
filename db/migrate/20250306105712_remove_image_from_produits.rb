class RemoveImageFromProduits < ActiveRecord::Migration[8.0]
  def change
    remove_column :produits, :image, :string
  end
end
