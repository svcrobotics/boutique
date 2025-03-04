class CreateFournisseurs < ActiveRecord::Migration[8.0]
  def change
    create_table :fournisseurs do |t|
      t.string :nom
      t.string :email
      t.string :telephone
      t.text :adresse

      t.timestamps
    end
  end
end
