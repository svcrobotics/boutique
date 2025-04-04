class AddPrenomToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :prenom, :string
  end
end
