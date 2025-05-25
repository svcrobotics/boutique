class CreateAvoirs < ActiveRecord::Migration[8.0]
  def change
    create_table :avoirs do |t|
      t.references :vente, null: false, foreign_key: true
      t.decimal :montant
      t.date :date
      t.boolean :utilise, default: false
      t.string :remarques

      t.timestamps
    end
  end
end
