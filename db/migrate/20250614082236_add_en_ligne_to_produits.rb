class AddEnLigneToProduits < ActiveRecord::Migration[8.0]
  def change
    add_column :produits, :en_ligne, :boolean, default: false, null: false
  end
end
