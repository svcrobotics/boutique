class CreateRemboursements < ActiveRecord::Migration[8.0]
  def change
    create_table :remboursements do |t|
      t.references :vente, null: false, foreign_key: true
      t.decimal :montant
      t.date :date
      t.string :mode
      t.string :motif

      t.timestamps
    end
  end
end
