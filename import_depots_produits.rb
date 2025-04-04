require 'roo'

xlsx = Roo::Spreadsheet.open('depots.xlsx')
sheet = xlsx.sheet(0)
header = sheet.row(1).map(&:downcase)

puts "En-têtes trouvées dans Excel : #{header.inspect}"

(2..sheet.last_row).each do |i|
  row = Hash[[ header, sheet.row(i) ].transpose]

  produit = Produit.new(
    nom: row["nom_article"],
    description: row["description"],
    prix_deposant: row["prix_initial"],
    prix: row["prix_vente"],
    client_id: row["deposante_id"],
    stock: row["stock"].to_i,
    categorie: row["categorie"],
    impression_code_barre: false,
    vendu: row["vendu"],
    en_depot: true,
    neuf: false,
    occasion: false,
    etat: "depot_vente",
    date_depot: row["date_depot"]
  )

  if produit.save
    puts "Produit #{produit.nom} importé avec succès."
  else
    puts "Erreur ligne #{i} : #{produit.errors.full_messages.join(', ')}"
  end
end

puts "Import terminé avec validation complète !"
