class AddVenteIdToProduitsVersements < ActiveRecord::Migration[8.0]
  def change
    add_column :produits_versements, :vente_id, :integer
    add_index :produits_versements, :vente_id
  end
end
