require 'roo'

# Ouvrir le fichier Excel
xlsx = Roo::Spreadsheet.open('deposantes.xlsx')

# Ouvrir la feuille Excel (première feuille par défaut)
sheet = xlsx.sheet(0)

# Parcourir chaque ligne (en ignorant la première ligne avec les en-têtes)
header = sheet.row(1).map(&:downcase) # noms des colonnes
(2..sheet.last_row).each do |i|
  row = Hash[[ header, sheet.row(i) ].transpose]

  # Adapter les noms des colonnes Excel selon ton modèle Client
  Client.create!(
    nom: row["nom"],
    prenom: row["prenom"],
    email: row["email"],
    telephone: row["telephone"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
    deposant: true, # Si le client importé est forcément déposant
    ancien_id: row["ancien_id"] # utile pour référencer l'ancien ID
  )
end

puts "Importation terminée avec succès !"
