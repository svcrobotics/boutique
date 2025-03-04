class AddImageToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :image, :string
  end
end
