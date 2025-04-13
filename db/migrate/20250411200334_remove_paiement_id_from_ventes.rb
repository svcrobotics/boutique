class RemovePaiementIdFromVentes < ActiveRecord::Migration[8.0]
  def change
    remove_reference :ventes, :paiement, null: false, foreign_key: true
  end
end
