class AddTotalBrutAndTotalNetToVentes < ActiveRecord::Migration[8.0]
  def change
    add_column :ventes, :total_brut, :decimal
    add_column :ventes, :total_net, :decimal
  end
end
