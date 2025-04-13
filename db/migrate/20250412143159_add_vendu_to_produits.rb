class AddVenduToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :vendu, :boolean, default: false
  end
end
