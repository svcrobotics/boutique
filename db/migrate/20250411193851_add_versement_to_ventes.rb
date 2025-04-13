class AddVersementToVentes < ActiveRecord::Migration[8.0]
  def change
    add_reference :ventes, :versement, foreign_key: true
  end
end
