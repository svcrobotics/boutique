class AddAncienIdToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :ancien_id, :string
  end
end
