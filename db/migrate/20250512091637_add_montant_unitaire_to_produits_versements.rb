class AddMontantUnitaireToProduitsVersements < ActiveRecord::Migration[8.0]
  def change
    add_column :produits_versements, :montant_unitaire, :decimal
  end
end
