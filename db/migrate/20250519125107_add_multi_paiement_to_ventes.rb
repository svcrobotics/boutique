class AddMultiPaiementToVentes < ActiveRecord::Migration[8.0]
  def change
    add_column :ventes, :multi_paiement, :text
  end
end
