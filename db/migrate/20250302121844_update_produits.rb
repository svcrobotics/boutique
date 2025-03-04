class UpdateProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :etat, :string
    add_column :produits, :en_depot, :boolean, default: false
    add_column :produits, :occasion, :boolean, default: false
    add_column :produits, :neuf, :boolean, default: false
    add_column :produits, :fournisseur_id, :integer
    add_column :produits, :observation, :text
    add_column :produits, :client_id, :integer
    add_column :produits, :date_depot, :date
    add_column :produits, :prix_deposant, :decimal, precision: 10, scale: 2
    add_column :produits, :vendu, :boolean, default: false
  end
end
