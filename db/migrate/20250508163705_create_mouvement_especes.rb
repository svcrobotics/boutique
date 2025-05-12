class CreateMouvementEspeces < ActiveRecord::Migration[8.0]
  def change
    create_table :mouvement_especes do |t|
      t.string :sens
      t.string :motif
      t.decimal :montant
      t.date :date
      t.string :compte

      t.timestamps
    end
  end
end
