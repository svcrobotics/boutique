class AddRemiseGlobaleToVentes < ActiveRecord::Migration[8.0]
  def change
    add_column :ventes, :remise_globale, :decimal
  end
end
