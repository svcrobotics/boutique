class AddMethodePaiementToVersements < ActiveRecord::Migration[8.0]
  def change
    add_column :versements, :methode_paiement, :string
  end
end
