class RenameTypeInClotures < ActiveRecord::Migration[8.0]
  def change
    rename_column :clotures, :type, :categorie
  end
end
