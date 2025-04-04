class CreateVersements < ActiveRecord::Migration[8.0]
  def change
    create_table :versements do |t|
      t.references :client, null: false, foreign_key: true
      t.references :produit, null: false, foreign_key: true
      t.references :vente, null: false, foreign_key: true
      t.decimal :montant
      t.date :date

      t.timestamps
    end
  end
end
