class RemoveVenteIdFromVersements < ActiveRecord::Migration[8.0]
  def change
    remove_reference :versements, :vente, null: false, foreign_key: true
  end
end
