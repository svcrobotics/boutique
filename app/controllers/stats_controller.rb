class StatsController < ApplicationController
  def index
    @stats = {}

    today = Date.today
    beginning_of_month = today.beginning_of_month
    end_of_month = today.end_of_month

    ventes = Vente.includes(ventes_produits: :produit, client: {})
    ventes_today = ventes.where(date_vente: today.all_day)
    ventes_month = ventes.where(date_vente: beginning_of_month..end_of_month)

    # Ventes aujourd'hui
    @stats[:today_count] = ventes_today.count
    @stats[:today_total] = ventes_today.sum { |v| v.total_ttc }

    # Ventes ce mois-ci
    @stats[:month_count] = ventes_month.count
    @stats[:month_total] = ventes_month.sum { |v| v.total_ttc }

    # Ventes totales
    @stats[:total_ventes] = ventes.count
    @stats[:total_ttc] = ventes.sum { |v| v.ventes_produits.sum { |vp| vp.quantite * vp.prix_unitaire } }

    # Marge totale
    @stats[:total_marge] = ventes.sum do |vente|
      vente.ventes_produits.sum do |vp|
        produit = vp.produit
        ttc = vp.quantite * vp.prix_unitaire
        if produit.en_depot?
          ttc - (produit.prix_deposant || 0)
        elsif produit.etat == "occasion"
          ttc - (produit.prix_achat || 0)
        else
          ttc
        end
      end
    end

    @stats[:marge_totale_mois] = ventes_month.sum do |vente|
      vente.ventes_produits.sum do |vp|
        produit = vp.produit
        quantite = vp.quantite
        prix_vente = vp.prix_unitaire * quantite

        marge =
          if produit.en_depot?
            prix_vente - (produit.prix_deposant || 0)
          elsif produit.etat == "occasion"
            prix_vente - (produit.prix_achat || 0)
          else
            prix_vente # produit neuf
          end

        marge
      end
    end


    # Top 3 produits les plus vendus (par quantité)
    top_produits = ventes.flat_map(&:ventes_produits)
                          .group_by { |vp| vp.produit.nom }
                          .transform_values { |vps| vps.sum(&:quantite) }
                          .sort_by { |_nom, qty| -qty }
                          .first(3)

    @stats[:top_produits] = Produit
                          .joins(:ventes_produits)
                          .select("produits.*, SUM(ventes_produits.quantite * ventes_produits.prix_unitaire) AS total_vendu")
                          .group("produits.id")
                          .order("total_vendu DESC")
                          .limit(5)

    # Top 3 déposantes les plus payées
    versements = Versement.includes(:client)
    top_deposantes = versements.group_by(&:client)
                               .transform_values { |vs| vs.sum(&:montant) }
                               .sort_by { |_client, total| -total }
                               .first(3)

    @stats[:top_deposantes] = Client
                               .joins(:versements)
                               .select("clients.*, SUM(versements.montant) AS total_verse")
                               .group("clients.id")
                               .order("total_verse DESC")
                               .limit(5)
  end
end
