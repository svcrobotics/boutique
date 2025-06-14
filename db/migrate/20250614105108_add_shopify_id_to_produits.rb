class AddShopifyIdToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :shopify_id, :string
  end
end
