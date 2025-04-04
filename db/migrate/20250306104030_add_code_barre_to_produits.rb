class AddCodeBarreToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :code_barre, :string
    add_column :produits, :impression_code_barre, :boolean
  end
end
