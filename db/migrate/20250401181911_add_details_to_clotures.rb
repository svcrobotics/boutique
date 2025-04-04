class AddDetailsToClotures < ActiveRecord::Migration[8.0]
  def change
    change_table :clotures do |t|
      t.integer :total_ventes
      t.integer :total_clients
      t.decimal :ticket_moyen, precision: 10, scale: 2

      t.decimal :total_cb, precision: 10, scale: 2, default: 0
      t.decimal :total_amex, precision: 10, scale: 2, default: 0
      t.decimal :total_especes, precision: 10, scale: 2, default: 0
      t.decimal :total_cheque, precision: 10, scale: 2, default: 0

      t.decimal :ht_0, precision: 10, scale: 2, default: 0
      t.decimal :ht_20, precision: 10, scale: 2, default: 0
      t.decimal :ttc_0, precision: 10, scale: 2, default: 0
      t.decimal :ttc_20, precision: 10, scale: 2, default: 0
      t.decimal :tva_20, precision: 10, scale: 2, default: 0

      t.decimal :total_remises, precision: 10, scale: 2, default: 0
      t.decimal :total_annulations, precision: 10, scale: 2, default: 0
      t.decimal :fond_caisse_initial, precision: 10, scale: 2, default: 0
      t.decimal :fond_caisse_final, precision: 10, scale: 2, default: 0
    end
  end
end
