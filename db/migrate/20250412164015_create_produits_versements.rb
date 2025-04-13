class CreateProduitsVersements < ActiveRecord::Migration[8.0]
  def change
    create_table :produits_versements do |t|
      t.references :produit, null: false, foreign_key: true
      t.references :versement, null: false, foreign_key: true
      t.integer :quantite

      t.timestamps
    end
  end
end
