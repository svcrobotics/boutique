class CreateFactures < ActiveRecord::Migration[8.0]
  def change
    create_table :factures do |t|
      t.string :numero
      t.date :date
      t.decimal :montant
      t.references :fournisseur, null: false, foreign_key: true
      t.string :fichier

      t.timestamps
    end
  end
end
