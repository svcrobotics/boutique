class AddPaiementsToVentes < ActiveRecord::Migration[8.0]
  def change
    add_column :ventes, :espece, :decimal
    add_column :ventes, :cb, :decimal
    add_column :ventes, :cheque, :decimal
    add_column :ventes, :amex, :decimal
    add_column :ventes, :avoir, :decimal
  end
end
