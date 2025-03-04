class AddDeposantToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :deposant, :boolean, default: false
  end
end
