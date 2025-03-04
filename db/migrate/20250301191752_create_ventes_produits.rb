class CreateVentesProduits < ActiveRecord::Migration[8.0]
  def change
    create_table :ventes_produits do |t|
      t.references :vente, null: false, foreign_key: true
      t.references :produit, null: false, foreign_key: true
      t.integer :quantite
      t.decimal :prix_unitaire

      t.timestamps
    end
  end
end
