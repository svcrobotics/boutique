class StatsController < ApplicationController
  def index
    @stats = {}

    today = Date.today
    beginning_of_month = today.beginning_of_month
    end_of_month = today.end_of_month

    ventes = Vente.includes(ventes_produits: :produit, client: {})
    ventes_today = ventes.where(date_vente: today.all_day)
    ventes_month = ventes.where(date_vente: beginning_of_month..end_of_month)

    # === Ventes aujourd'hui ===
    @stats[:today_count] = ventes_today.count
    @stats[:today_total] = ventes_today.sum(&:total_ttc)

    # === Ventes ce mois-ci ===
    @stats[:month_count] = ventes_month.count
    @stats[:month_total] = ventes_month.sum(&:total_ttc)

    # === Ventes totales ===
    @stats[:total_ventes] = ventes.count
    @stats[:total_ttc] = ventes.sum(&:total_ttc)

    # === Marge totale toutes ventes ===
    @stats[:total_marge] = ventes.sum do |vente|
      vente.ventes_produits.sum do |vp|
        produit = vp.produit
        quantite = vp.quantite
        prix_vente_total = vp.prix_unitaire * quantite

        cout_total = if produit.en_depot?
          (produit.prix_deposant || 0) * quantite
        else
          (produit.prix_achat || 0) * quantite
        end

        prix_vente_total - cout_total
      end
    end

    # Calcul TVA à payer (20%)
    @stats[:tva_a_payer_totale] = ventes.sum do |vente|
      vente.ventes_produits.sum do |vp|
        produit = vp.produit
        quantite = vp.quantite
        prix_unitaire = vp.prix_unitaire

        base_tva =
          case
          when produit.en_depot?
            (prix_unitaire - (produit.prix_deposant || 0)) * quantite
          when produit.etat == "occasion"
            (prix_unitaire - (produit.prix_achat || 0)) * quantite
          else # produit neuf
            prix_unitaire * quantite
          end

        base_tva > 0 ? base_tva * 0.20 : 0
      end
    end


    # === Marge totale ce mois ===
    @stats[:marge_totale_mois] = ventes_month.sum do |vente|
      vente.ventes_produits.sum do |vp|
        produit = vp.produit
        quantite = vp.quantite
        prix_vente_total = vp.prix_unitaire * quantite

        cout_total = if produit.en_depot?
          (produit.prix_deposant || 0) * quantite
        else
          (produit.prix_achat || 0) * quantite
        end

        prix_vente_total - cout_total
      end
    end

    # === Top 5 produits par chiffre d'affaires ===
    @stats[:top_produits] = Produit
                            .joins(:ventes_produits)
                            .select("produits.*, SUM(ventes_produits.quantite * ventes_produits.prix_unitaire) AS total_vendu")
                            .group("produits.id")
                            .order("total_vendu DESC")
                            .limit(5)

    # === Top 5 déposantes par montant versé ===
    @stats[:top_deposantes] = Client
                              .joins(:versements)
                              .select("clients.*, SUM(versements.montant) AS total_verse")
                              .group("clients.id")
                              .order("total_verse DESC")
                              .limit(5)
  end
end
