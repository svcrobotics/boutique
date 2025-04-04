class CreateJoinTableVersementsVentes < ActiveRecord::Migration[8.0]
  def change
    create_join_table :versements, :ventes do |t|
      t.index [ :versement_id, :vente_id ]
      t.index [ :vente_id, :versement_id ]
    end
  end
end
