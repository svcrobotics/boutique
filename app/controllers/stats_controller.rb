class StatsController < ApplicationController
  def index
    @stats = {}

    today = Date.current
    beginning_of_month = today.beginning_of_month
    end_of_month = today.end_of_month

    ventes = Vente.includes(ventes_produits: :produit, client: {})
    ventes_today = ventes.where(date_vente: today.all_day)
    ventes_month = ventes.where(date_vente: beginning_of_month..end_of_month)

    # === Ventes aujourd'hui ===
    @stats[:today_count] = ventes_today.count
    @stats[:today_total_net] = ventes_today.sum(&:total_net)

    # === Ventes ce mois-ci ===
    @stats[:month_count] = ventes_month.count
    @stats[:month_total_net] = ventes_month.sum(&:total_net)

    # === Marge totale ce mois ===
    @stats[:marge_totale_mois] = ventes_month.sum do |vente|
      vente.ventes_produits.sum do |vp|
        produit = vp.produit
        quantite = vp.quantite
        prix_vente_total = vp.prix_unitaire * quantite
        remise = prix_vente_total * (vp.remise.to_d / 100)
        net = prix_vente_total - remise

        cout_total = if produit.en_depot?
          (produit.prix_deposant || 0) * quantite
        else
          (produit.prix_achat || 0) * quantite
        end

        net - cout_total
      end
    end

    # === TVA à payer ce mois (uniquement sur produits neufs)
    @stats[:tva_a_payer_totale] = ventes_month.sum do |vente|
      vente.ventes_produits.select { |vp| vp.produit.etat == "neuf" }.sum do |vp|
        total = vp.quantite * vp.prix_unitaire
        remise = total * (vp.remise.to_d / 100)
        net_ttc = total - remise
        (net_ttc / 1.2 * 0.2).round(2)
      end
    end

    # === (Facultatif) Top produits vendus
    @stats[:top_produits] = Produit
      .joins(:ventes_produits)
      .select("produits.*, SUM(ventes_produits.quantite * ventes_produits.prix_unitaire * (1 - ventes_produits.remise / 100.0)) AS total_vendu")
      .group("produits.id")
      .order("total_vendu DESC")
      .limit(5)

    # === (Facultatif) Top déposantes payées
    @stats[:top_deposantes] = Client
      .joins(:versements)
      .select("clients.*, SUM(versements.montant) AS total_verse")
      .group("clients.id")
      .order("total_verse DESC")
      .limit(5)
  end
end
