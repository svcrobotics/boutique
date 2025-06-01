class AddMotifToAvoirs < ActiveRecord::Migration[8.0]
  def change
    add_column :avoirs, :motif, :string
  end
end
