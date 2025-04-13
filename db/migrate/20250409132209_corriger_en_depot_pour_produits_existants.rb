class CorrigerEnDepotPourProduitsExistants < ActiveRecord::Migration[7.1]
  def up
    Produit.reset_column_information
    Produit.find_each do |produit|
      produit.update_column(:en_depot, produit.etat == 'depot_vente')
    end
  end

  def down
    # Pas nécessaire
  end
end
