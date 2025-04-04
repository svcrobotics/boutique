require 'sqlite3'
require 'caxlsx'

db = SQLite3::Database.new('storage/development.sqlite3')

columns, *rows = db.execute2("SELECT id, nom, categorie FROM produits")

Axlsx::Package.new do |p|
  p.workbook.add_worksheet(name: "Produits") do |sheet|
    sheet.add_row columns
    rows.each { |row| sheet.add_row row }
  end
  p.serialize("produits.xlsx")
end

puts "Export terminé vers produits.xlsx"
