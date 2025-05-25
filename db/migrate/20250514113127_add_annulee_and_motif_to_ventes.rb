class AddAnnuleeAndMotifToVentes < ActiveRecord::Migration[8.0]
  def change
    add_column :ventes, :annulee, :boolean
    add_column :ventes, :motif_annulation, :string
  end
end
