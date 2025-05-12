class CreateReassorts < ActiveRecord::Migration[8.0]
  def change
    create_table :reassorts do |t|
      t.references :produit, null: false, foreign_key: true
      t.integer :quantite
      t.date :date
      t.decimal :prix_achat
      t.boolean :remise
      t.integer :taux_remise

      t.timestamps
    end
  end
end
