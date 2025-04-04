class CreatePaiements < ActiveRecord::Migration[8.0]
  def change
    create_table :paiements do |t|
      t.decimal :montant
      t.date :date_paiement
      t.string :methode_paiement
      t.boolean :effectue
      t.integer :numero_recu
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
