namespace :fix do
  desc "Lier les ventes aux paiements déjà effectués"
  task lier_paiements: :environment do
    puts "🔄 Liaison des ventes aux paiements..."

    Paiement.includes(:client).find_each do |paiement|
      client = paiement.client
      ventes_concernees = []

      client.produits.each do |produit|
        next unless produit.en_depot? && produit.vendu?

        produit.ventes.each do |vente|
          unless PaiementsVente.exists?(paiement: paiement, vente: vente)
            PaiementsVente.create!(paiement: paiement, vente: vente)
            ventes_concernees << vente
          end
        end
      end

      puts "✅ Paiement ##{paiement.id} → #{ventes_concernees.size} ventes liées"
    end

    puts "🎉 Liaison des paiements terminée."
  end
end
