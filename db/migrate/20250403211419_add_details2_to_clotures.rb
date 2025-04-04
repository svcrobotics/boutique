class AddDetails2ToClotures < ActiveRecord::Migration[8.0]
  def change
    add_column :clotures, :total_versements, :decimal
    add_column :clotures, :total_encaisse, :decimal
    add_column :clotures, :total_articles, :integer
  end
end
