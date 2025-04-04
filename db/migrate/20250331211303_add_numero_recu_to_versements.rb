class AddNumeroRecuToVersements < ActiveRecord::Migration[8.0]
  def change
    add_column :versements, :numero_recu, :string
  end
end
