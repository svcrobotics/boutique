class AddVenteToMouvementEspeces < ActiveRecord::Migration[8.0]
  def change
    add_reference :mouvement_especes, :vente, null: true, foreign_key: true
  end
end
