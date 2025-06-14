class AddPhotosUrlToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :photos_url, :text
  end
end
