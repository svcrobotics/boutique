class ModifyVentes < ActiveRecord::Migration[8.0]
  def change
    remove_column :ventes, :produit_id, :integer
    add_column :ventes, :total, :decimal, precision: 10, scale: 2
    add_column :ventes, :mode_paiement, :string
  end
end
