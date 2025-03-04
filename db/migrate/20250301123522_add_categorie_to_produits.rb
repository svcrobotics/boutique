class AddCategorieToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :categorie, :string, default: "vêtement", null: false
  end
end
