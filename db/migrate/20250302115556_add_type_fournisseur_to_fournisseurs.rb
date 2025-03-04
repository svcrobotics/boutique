class AddTypeFournisseurToFournisseurs < ActiveRecord::Migration[8.0]
  def change
    add_column :fournisseurs, :type_fournisseur, :string
  end
end
