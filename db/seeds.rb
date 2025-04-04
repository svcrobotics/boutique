# Récupérer le fournisseur existant
emporium = Fournisseur.find_by(nom: "Emporium")

unless emporium
  puts "❌ Le fournisseur 'Emporium' n'existe pas dans la base. Ajoutez-le d'abord."
  exit
end

begin
  date = Date.parse("2025-03-14")
rescue ArgumentError
  date = nil
end

# Liste complète des produits à ajouter
produits = [
  { code_fournisseur: "522727", nom: "Veste", prix_achat: 16, stock: 6 },
  { code_fournisseur: "9802", nom: "Robe", prix_achat: 18, stock: 2 },
  { code_fournisseur: "814136", nom: "Pantalon", prix_achat: 12, stock: 25 },
  { code_fournisseur: "2329", nom: "Pull", prix_achat: 16.5, stock: 2 },
  { code_fournisseur: "8123", nom: "Pantalon", prix_achat: 16.5, stock: 29 },
  { code_fournisseur: "P6", nom: "Pull", prix_achat: 6, stock: 20 }
]

produits.each do |prod|
  # Vérifier si le produit existe déjà avec le même `code_fournisseur`
  existing_product = Produit.find_by(code_fournisseur: prod[:code_fournisseur])

  if existing_product
    puts "⚠️ Produit '#{prod[:nom]}' (Code: #{prod[:code_fournisseur]}) existe déjà, il ne sera pas ajouté."
  else
    produit = Produit.new(
      code_fournisseur: prod[:code_fournisseur],
      nom: prod[:nom],
      prix_achat: prod[:prix_achat],
      stock: prod[:stock],
      fournisseur: emporium,
      etat: "neuf",
      categorie: "vêtement",
      impression_code_barre: true, # Ajout de la valeur par défaut
      date_achat: date
    )

    if produit.valid?
      produit.save!
      puts "✅ Produit '#{produit.nom}' ajouté avec succès."
    else
      puts "❌ ERREUR: Impossible d'ajouter '#{produit.nom}'"
      puts "Problèmes détectés :"
      puts produit.errors.full_messages.join("\n")
    end
  end
end

puts "🎉 Seed terminé !"
