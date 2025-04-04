class RemoveProduitIdFromVersements < ActiveRecord::Migration[8.0]
  def change
    remove_reference :versements, :produit, null: false, foreign_key: true
  end
end
