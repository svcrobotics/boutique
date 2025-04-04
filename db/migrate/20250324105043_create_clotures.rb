class CreateClotures < ActiveRecord::Migration[8.0]
  def change
    create_table :clotures do |t|
      t.string :type
      t.date :date
      t.decimal :total_ht
      t.decimal :total_tva
      t.decimal :total_ttc

      t.timestamps
    end
  end
end
