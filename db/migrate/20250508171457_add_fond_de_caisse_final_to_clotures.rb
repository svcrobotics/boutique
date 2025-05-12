class AddFondDeCaisseFinalToClotures < ActiveRecord::Migration[8.0]
  def change
    add_column :clotures, :fond_de_caisse_final, :decimal
  end
end
