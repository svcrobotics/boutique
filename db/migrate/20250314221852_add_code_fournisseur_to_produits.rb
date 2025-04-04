class AddCodeFournisseurToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :code_fournisseur, :string
  end
end
