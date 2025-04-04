require 'roo'

xlsx = Roo::Spreadsheet.open('produits.xlsx')
sheet = xlsx.sheet(0)
header = sheet.row(1).map(&:downcase)

(2..sheet.last_row).each do |i|
  row = Hash[[header, sheet.row(i)].transpose]

  produit = Produit.find_by(id: row["id"])

  if produit
    produit.update(categorie: row["categorie"])
    puts "✅ Produit #{produit.id} mis à jour : catégorie = #{produit.categorie}"
  else
    puts "❌ Produit avec ID #{row['id']} introuvable."
  end
end

puts "Mise à jour des catégories terminée."
