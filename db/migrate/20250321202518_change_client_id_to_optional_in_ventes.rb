class ChangeClientIdToOptionalInVentes < ActiveRecord::Migration[8.0]
  def change
    # dans la migration créée
    change_column :ventes, :client_id, :integer, null: true
  end
end
