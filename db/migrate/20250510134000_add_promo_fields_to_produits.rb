class AddPromoFieldsToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :en_promo, :boolean
    add_column :produits, :prix_promo, :decimal
  end
end
