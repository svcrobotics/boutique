class RemoveOldPaiementFieldsFromVentes < ActiveRecord::Migration[8.0]
  def change
    remove_column :ventes, :mode_paiement, :string
    remove_column :ventes, :multi_paiement, :text
    remove_column :ventes, :avoir, :decimal
  end
end
