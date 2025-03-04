class AddDetailsToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :prix_achat, :decimal, precision: 10, scale: 2
    add_column :produits, :date_achat, :date
    add_column :produits, :facture, :string
  end
end
