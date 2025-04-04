class CreatePaiementsVentes < ActiveRecord::Migration[8.0]
  def change
    create_table :paiements_ventes do |t|
      t.references :paiement, null: false, foreign_key: true
      t.references :vente, null: false, foreign_key: true

      t.timestamps
    end
  end
end
