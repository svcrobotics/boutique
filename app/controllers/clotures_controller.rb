# Contrôleur gérant les clôtures journalières et mensuelles de caisse.
class CloturesController < ApplicationController
  require "ostruct"
  ##
  # Affiche la liste des clôtures, triées par date décroissante.
  def index
    @clotures = Cloture.order(date: :desc)
    
    fond_initial = 0

    entrees = MouvementEspece.where(date: Date.today, sens: "entrée").sum(:montant)
    sorties = MouvementEspece.where(date: Date.today, sens: "sortie").sum(:montant)
    versements = Versement.where(methode_paiement: "Espèces", created_at: Date.today.all_day).sum(:montant)

    @fond_caisse_theorique = fond_initial + entrees - sorties - versements

  end

  def refresh_fond_caisse
    cloture_hier = Cloture.where(categorie: "journalier").where("date < ?", Date.today).order(date: :desc).first
    fond_initial = 0 # on force à 0 puisque tu veux repartir à zéro

    entrees = MouvementEspece.where(date: Date.today, sens: "entrée").sum(:montant)
    sorties = MouvementEspece.where(date: Date.today, sens: "sortie").sum(:montant)
    versements = Versement.where(methode_paiement: "Espèces", created_at: Date.today.all_day).sum(:montant)

    @fond_caisse_theorique = fond_initial + entrees - sorties - versements

    redirect_to clotures_path, notice: "✅ Fond de caisse théorique recalculé : #{sprintf('%.2f €', @fond_caisse_theorique)}"
  end

  ##
  # Affiche le détail d'une clôture journalière : nombre de ventes, total par mode de paiement,
  # total TTC, HT, TVA, répartis selon le taux de TVA appliqué.
  #
  # @note Cette méthode ne s'applique pas aux clôtures mensuelles.
  def show
    @cloture = Cloture.find(params[:id])
    ventes = Vente.includes(ventes_produits: :produit).where(date_vente: @cloture.date.all_day)

    @ventes_count = ventes.count
    @articles_count = ventes.sum { |v| v.ventes_produits.sum(&:quantite) }

    @total_cb = ventes.where(mode_paiement: "CB").sum(:total_net)
    @total_amex = ventes.where(mode_paiement: "AMEX").sum(:total_net)
    @total_especes = ventes.where(mode_paiement: "Espèces").sum(:total_net)
    @total_cheque = ventes.where(mode_paiement: "Chèque").sum(:total_net)

    @ttc_0 = @ttc_20 = @remises = 0

    ventes.each do |vente|
      vente.ventes_produits.each do |vp|
        total = (vp.prix_unitaire * vp.quantite) - vp.remise.to_f
        @remises += vp.remise.to_f
        if vp.produit.etat == "neuf"
          @ttc_20 += total
        else
          @ttc_0 += total
        end
      end
    end

    @ht_20   = (@ttc_20 / 1.2).round(2)
    @tva_20  = (@ttc_20 - @ht_20).round(2)
    @ht_0    = @ttc_0
    @tva_0   = 0

    @ht_total  = (@ht_0 + @ht_20).round(2)
    @tva_total = (@tva_0 + @tva_20).round(2)
    @ttc_total = (@ttc_0 + @ttc_20).round(2)

    @total_remises = @remises
  end

  ##
  # Génère une clôture mensuelle à partir des clôtures journalières du mois donné,
  # puis imprime le ticket correspondant.
  #
  # @param [String] mois Le mois au format "YYYY-MM" (ex: "2025-04")
  # @return [Redirect] Redirige avec une notification de succès ou d'erreur
  def cloture_mensuelle
    mois = params[:mois]

    begin
      date = Date.parse("#{mois}-01")
    rescue ArgumentError
      redirect_to clotures_path, alert: "❌ Format de date invalide. Utilise AAAA-MM."
      return
    end

    if Cloture.exists?(date: date.end_of_month, categorie: "mensuelle")
      redirect_to clotures_path, alert: "❌ Clôture mensuelle déjà enregistrée pour #{mois}."
      return
    end

    clotures_jour = Cloture.where(
      categorie: "journalier",
      date: date.beginning_of_month..date.end_of_month
    )

    if clotures_jour.empty?
      redirect_to clotures_path, alert: "❌ Aucune clôture journalière trouvée pour ce mois."
      return
    end

    # Total versements
    total_versements = Versement
      .joins(:produits)
      .where(created_at: date.beginning_of_month..date.end_of_month)
      .sum("produits_versements.quantite * produits_versements.montant_unitaire")

    ventes_du_mois = Vente.includes(ventes_produits: :produit)
      .where(date_vente: date.beginning_of_month..date.end_of_month)

    total_articles = ventes_du_mois.sum { |v| v.ventes_produits.sum(&:quantite) }

    # Création en base
    cloture = Cloture.create!(
      categorie: "mensuelle",
      date: date.end_of_month,
      total_ht: clotures_jour.sum(:total_ht),
      total_tva: clotures_jour.sum(:total_tva),
      total_ttc: clotures_jour.sum(:total_ttc),
      total_versements: total_versements,
      total_cb: clotures_jour.sum(:total_cb),
      total_amex: clotures_jour.sum(:total_amex),
      total_especes: clotures_jour.sum(:total_especes),
      total_cheque: clotures_jour.sum(:total_cheque),
      total_encaisse: clotures_jour.sum(:total_encaisse),
      total_ventes: clotures_jour.sum(:total_ventes),
      total_clients: clotures_jour.sum(:total_clients),
      total_articles: total_articles,
      ticket_moyen: clotures_jour.average(:ticket_moyen).to_f.round(2),
      ht_0: clotures_jour.sum(:ht_0),
      ht_20: clotures_jour.sum(:ht_20),
      ttc_0: clotures_jour.sum(:ttc_0),
      ttc_20: clotures_jour.sum(:ttc_20),
      tva_20: clotures_jour.sum(:tva_20),
      total_remises: clotures_jour.sum(:total_remises),
      total_annulations: clotures_jour.sum(:total_annulations)
    )

    # OpenStruct pour impression
    data = OpenStruct.new(
      categorie: "mensuelle",
      date: date.end_of_month,
      ouverture: date.beginning_of_month,
      total_ht: cloture.total_ht,
      total_tva: cloture.total_tva,
      total_ttc: cloture.total_ttc,
      total_versements: total_versements,
      total_cb: cloture.total_cb,
      total_amex: cloture.total_amex,
      total_especes: cloture.total_especes,
      total_cheque: cloture.total_cheque,
      total_encaisse: cloture.total_encaisse,
      total_ventes: cloture.total_ventes,
      total_clients: cloture.total_clients,
      total_articles: cloture.total_articles,
      ticket_moyen: cloture.ticket_moyen,
      ht_0: cloture.ht_0,
      ht_20: cloture.ht_20,
      ttc_0: cloture.ttc_0,
      ttc_20: cloture.ttc_20,
      tva_20: cloture.tva_20,
      total_remises: cloture.total_remises,
      total_annulations: cloture.total_annulations,
      details_ventes: [],
      details_versements: []
    )

    # Impression
    path_utf8 = Rails.root.join("tmp", "z_ticket_mensuel.txt")
    path_cp   = Rails.root.join("tmp", "z_ticket_mensuel_cp858.txt")

    File.write(path_utf8, cloture_ticket_texte(data))
    system("iconv -f UTF-8 -t CP858 #{path_utf8} -o #{path_cp}")
    system("lp", "-d", "SEWOO_LKT_Series", "#{path_cp}")

    redirect_to clotures_path, notice: "✅ Clôture mensuelle de #{mois} enregistrée et imprimée."
  end



  ##
  # Imprime un ticket de clôture mensuelle ou journalière.
  #
  # @param [Integer] id Identifiant de la clôture à imprimer
  # @return [Redirect] Redirige vers la liste avec une notification
  def imprimer
    cloture = Cloture.find(params[:id])

    # Total versements
    total_versements = Versement
      .joins(:produits)
      .where(created_at: cloture.date.beginning_of_month..cloture.date.end_of_month)
      .sum("produits_versements.quantite * produits_versements.montant_unitaire")

    ventes_du_mois = Vente.includes(ventes_produits: :produit)
      .where(date_vente: cloture.date.beginning_of_month..cloture.date.end_of_month)

    total_articles = ventes_du_mois.sum { |v| v.ventes_produits.sum(&:quantite) }

    # Si c’est une clôture mensuelle, pas besoin de recalculer à partir des ventes
    if cloture.categorie == "mensuelle"
      data = OpenStruct.new(
        categorie: "mensuelle",
        date: cloture.date,
        ouverture: cloture.date.beginning_of_month,
        total_ventes: cloture.total_ventes,
        total_clients: cloture.total_clients,
        total_articles: total_articles,
        ticket_moyen: cloture.ticket_moyen,
        total_cb: cloture.total_cb,
        total_amex: cloture.total_amex,
        total_especes: cloture.total_especes,
        total_cheque: cloture.total_cheque,
        total_encaisse: cloture.total_encaisse,
        ht_0: cloture.ht_0,
        ht_20: cloture.ht_20,
        ttc_0: cloture.ttc_0,
        ttc_20: cloture.ttc_20,
        tva_20: cloture.tva_20,
        total_ht: cloture.total_ht,
        total_tva: cloture.total_tva,
        total_ttc: cloture.total_ttc,
        total_remises: cloture.total_remises,
        total_annulations: cloture.total_annulations,
        total_versements: total_versements,
        details_ventes: [],
        details_versements: []
      )
    else
      # Clôture journalière : on recalcule à partir des ventes du jour
      ventes = Vente.includes(ventes_produits: :produit).where(date_vente: cloture.date.all_day)

      total_ventes = ventes.count
      total_clients = ventes.map(&:client_id).compact.uniq.size
      total_articles = ventes.sum { |v| v.ventes_produits.sum(&:quantite) }

      total_cb      = ventes.where(mode_paiement: "CB").sum(&:total_net)
      total_amex    = ventes.where(mode_paiement: "AMEX").sum(&:total_net)
      total_especes = ventes.where(mode_paiement: "Espèces").sum(&:total_net)
      total_cheque  = ventes.where(mode_paiement: "Chèque").sum(&:total_net)
      total_encaisse = total_cb + total_amex + total_especes + total_cheque

      ht_0 = ttc_0 = ht_20 = ttc_20 = total_remises = 0

      ventes.each do |vente|
        vente.ventes_produits.each do |vp|
          prix_unitaire = vp.prix_unitaire.to_f > 0 ? vp.prix_unitaire : vp.produit.prix
          remise = vp.remise.to_f
          montant = prix_unitaire * vp.quantite * (1 - remise / 100.0)
          total_remises += prix_unitaire * vp.quantite * (remise / 100.0)

          if vp.produit.etat == "neuf"
            ttc_20 += montant
          else
            ttc_0 += montant
          end
        end
      end

      ht_20  = (ttc_20 / 1.2).round(2)
      tva_20 = (ttc_20 - ht_20).round(2)
      ht_0   = ttc_0
      total_ht  = (ht_0 + ht_20).round(2)
      total_tva = tva_20
      total_ttc = (ttc_0 + ttc_20).round(2)
      ticket_moyen = total_ventes.positive? ? (total_ttc / total_ventes).round(2) : 0

      total_annulations = 0
      # Fond de caisse initial = fond laissé la veille

      jour = cloture.date

      cloture_hier = Cloture.where(categorie: "journalier", date: ..(jour - 1)).order(date: :desc).first
      fond_caisse_initial = 0

      # Fond de caisse final = ce que l’utilisateur a saisi manuellement
      fond_caisse_final = params[:fond_caisse_final].to_d rescue total_especes

      total_versements = Versement.where(created_at: cloture.date.all_day).sum(:montant)

      data = OpenStruct.new(
        categorie: "journalier",
        date: cloture.date,
        ouverture: ventes.minimum(:created_at),
        total_ventes: total_ventes,
        total_articles: total_articles,
        total_clients: total_clients,
        ticket_moyen: ticket_moyen,
        total_cb: total_cb,
        total_amex: total_amex,
        total_especes: total_especes,
        total_cheque: total_cheque,
        total_encaisse: total_encaisse,
        ht_0: ht_0,
        ht_20: ht_20,
        ttc_0: ttc_0,
        ttc_20: ttc_20,
        tva_20: tva_20,
        total_ht: cloture.total_ht,
        total_tva: cloture.total_tva,
        total_ttc: cloture.total_ttc,
        total_remises: cloture.total_remises,
        total_annulations: cloture.total_annulations,
        fond_caisse_initial: cloture.fond_caisse_initial,
        fond_caisse_final: cloture.fond_caisse_final,
        total_versements: cloture.total_versements || 0,
        details_ventes: ventes.flat_map do |vente|
          vente.ventes_produits.map do |vp|
            produit = vp.produit
            prix_unitaire = vp.prix_unitaire.to_f > 0 ? vp.prix_unitaire : produit.prix
            remise = vp.remise.to_f
            montant_total = (prix_unitaire * vp.quantite * (1 - remise / 100)).round(2)

            {
              heure: vente.date_vente.strftime("%H:%M"),
              nom: produit.nom.truncate(25),
              etat: produit.etat.capitalize,
              paiement: vente.mode_paiement,
              quantite: vp.quantite,
              prix_unitaire: prix_unitaire,
              remise: remise,
              montant_total: montant_total
            }
          end
        end,
        details_versements: Versement.includes(client: {}, ventes: { ventes_produits: :produit })
        .where(created_at: cloture.date.all_day)
        .map do |versement|
          produits = versement.ventes.flat_map(&:ventes_produits).map(&:produit)
          produits_client = produits.select { |p| p.client_id == versement.client_id }

          {
            heure: versement.created_at.strftime("%H:%M"),
            client: "#{versement.client.nom} #{versement.client.prenom}",
            montant: versement.montant,
            numero_recu: versement.numero_recu,
            produits: produits_client.group_by(&:id).map do |_, ps|
              produit = ps.first
              quantite = versement.ventes.sum do |vente|
                vente.ventes_produits.where(produit_id: produit.id).sum(:quantite)
              end

              {
                nom: produit.nom.truncate(25),
                etat: produit.etat.capitalize,
                quantite: quantite,
                total: (quantite * produit.prix_deposant).round(2)
              }
            end
          }
        end
      )
    end

    # Impression
    texte = cloture_ticket_texte(data)

    File.write(Rails.root.join("tmp/z_ticket.txt"), texte)
    system("iconv -f UTF-8 -t CP858 tmp/z_ticket.txt -o tmp/z_ticket_cp858.txt")
    system("lp", "-d", "SEWOO_LKT_Series", "tmp/z_ticket_cp858.txt")


    redirect_to clotures_path, notice: "✅ Clôture imprimée avec succès."
  end


  ##
  # Crée une clôture journalière (ticket Z) si elle n'existe pas déjà pour le jour donné
  # et imprime un récapitulatif détaillé.
  #
  # @param [Date] date (optionnel) Date à clôturer, sinon la date courante est utilisée
  # @return [Redirect] Redirige vers la liste des ventes ou des clôtures avec une notification
  def cloture_z
    jour = params[:date].present? ? Date.parse(params[:date]) : Date.current
    # Fond de caisse initial : toujours 0 car on remet à zéro chaque jour
    fond_caisse_initial = 0

    return redirect_to ventes_path, alert: "Clôture déjà effectuée pour aujourd’hui." if Cloture.exists?(date: jour, categorie: "journalier")

    ventes = Vente.includes(:client, ventes_produits: :produit).where(date_vente: jour.all_day)
    return redirect_to ventes_path, alert: "Aucune vente pour aujourd’hui." if ventes.empty?

    total_ventes = ventes.count
    total_clients = ventes.map(&:client_id).compact.uniq.size
    total_articles = ventes.sum { |v| v.ventes_produits.sum(&:quantite) }

    total_cb      = ventes.where(mode_paiement: "CB").sum(&:total_net)
    total_amex    = ventes.where(mode_paiement: "AMEX").sum(&:total_net)
    total_especes = ventes.where(mode_paiement: "Espèces").sum(&:total_net)
    total_cheque  = ventes.where(mode_paiement: "Chèque").sum(&:total_net)
    total_encaisse = total_cb + total_amex + total_especes + total_cheque

    ht_0 = ttc_0 = ht_20 = ttc_20 = total_remises = 0

    ventes.each do |vente|
      vente.ventes_produits.each do |vp|
        prix_unitaire = vp.prix_unitaire.to_f > 0 ? vp.prix_unitaire : vp.produit.prix
        remise = vp.remise.to_f
        montant = prix_unitaire * vp.quantite * (1 - remise / 100.0)
        total_remises += prix_unitaire * vp.quantite * (remise / 100.0)

        if vp.produit.etat == "neuf"
          ttc_20 += montant
        else
          ttc_0 += montant
        end
      end
    end

    ht_20  = (ttc_20 / 1.2).round(2)
    tva_20 = (ttc_20 - ht_20).round(2)
    ht_0   = ttc_0
    total_ht  = (ht_0 + ht_20).round(2)
    total_tva = tva_20
    total_ttc = (ttc_0 + ttc_20).round(2)
    ticket_moyen = total_ventes.positive? ? (total_ttc / total_ventes).round(2) : 0

    total_annulations = 0
    
    jour = params[:date].present? ? Date.parse(params[:date]) : Date.current

    # Fond de caisse initial = fond laissé la veille
    cloture_hier = Cloture.where(categorie: "journalier", date: ..(jour - 1)).order(date: :desc).first
    fond_caisse_initial = 0

    # Fond de caisse final = ce que l’utilisateur a saisi manuellement
    fond_caisse_final = params[:fond_caisse_final].to_d rescue total_especes

    total_versements = Versement.where(created_at: jour.all_day).sum(:montant)

    Cloture.create!(
      categorie: "journalier",
      date: jour,
      total_ht: total_ht,
      total_tva: total_tva,
      total_ttc: total_ttc,
      total_ventes: total_ventes,
      total_clients: total_clients,
      total_articles: total_articles,
      ticket_moyen: ticket_moyen,
      total_cb: total_cb,
      total_amex: total_amex,
      total_cheque: total_cheque,
      total_especes: total_especes,
      total_encaisse: total_encaisse,
      ht_0: ht_0,
      ht_20: ht_20,
      ttc_0: ttc_0,
      ttc_20: ttc_20,
      tva_20: tva_20,
      total_remises: total_remises.round(2),
      total_annulations: total_annulations,
      fond_caisse_initial: fond_caisse_initial,
      fond_caisse_final: fond_caisse_final,
      total_versements: total_versements
    )

    data = OpenStruct.new(
      date: jour,
      ouverture: ventes.minimum(:created_at),
      total_ventes: total_ventes,
      total_clients: total_clients,
      total_articles: total_articles,
      ticket_moyen: ticket_moyen,
      total_cb: total_cb,
      total_amex: total_amex,
      total_cheque: total_cheque,
      total_especes: total_especes,
      total_encaisse: total_encaisse,
      ht_0: ht_0,
      ht_20: ht_20,
      ttc_0: ttc_0,
      ttc_20: ttc_20,
      tva_20: tva_20,
      total_ht: total_ht,
      total_tva: total_tva,
      total_ttc: total_ttc,
      total_remises: total_remises.round(2),
      total_annulations: total_annulations,
      fond_caisse_initial: fond_caisse_initial,
      fond_caisse_final: fond_caisse_final,
      total_versements: total_versements,
      details_ventes: ventes.flat_map do |vente|
        vente.ventes_produits.map do |vp|
          produit = vp.produit
          prix_unitaire = vp.prix_unitaire.to_f > 0 ? vp.prix_unitaire : produit.prix
          remise = vp.remise.to_f
          montant_total = (prix_unitaire * vp.quantite * (1 - remise / 100)).round(2)

          {
            heure: vente.date_vente.strftime("%H:%M"),
            nom: produit.nom.truncate(25),
            etat: produit.etat.capitalize,
            paiement: vente.mode_paiement,
            quantite: vp.quantite,
            prix_unitaire: prix_unitaire,
            remise: remise,
            montant_total: montant_total
          }
        end
      end,
      details_versements: Versement.includes(client: {}, ventes: { ventes_produits: :produit })
        .where(created_at: jour.all_day)
        .map do |versement|
          produits = versement.ventes.flat_map(&:ventes_produits).map(&:produit)
          produits_client = produits.select { |p| p.client_id == versement.client_id }

          {
            heure: versement.created_at.strftime("%H:%M"),
            client: "#{versement.client.nom} #{versement.client.prenom}",
            montant: versement.montant,
            numero_recu: versement.numero_recu,
            produits: produits_client.group_by(&:id).map do |_, ps|
              produit = ps.first
              quantite = versement.ventes.sum do |vente|
                vente.ventes_produits.where(produit_id: produit.id).sum(:quantite)
              end

              {
                nom: produit.nom.truncate(25),
                etat: produit.etat.capitalize,
                quantite: quantite,
                total: (quantite * produit.prix_deposant).round(2)
              }
            end
          }
        end
    )

    texte = cloture_ticket_texte(data)

    # File.write(Rails.root.join("tmp/z_ticket.txt"), texte)
    # system("iconv -f UTF-8 -t CP858 tmp/z_ticket.txt -o tmp/z_ticket_cp858.txt")
    # system("lp", "-d", "SEWOO_LKT_Series", "tmp/z_ticket_cp858.txt")

    redirect_to clotures_path, notice: "✅ Clôture générée sans impression automatique."
  end



  def preview
    cloture = Cloture.find(params[:id])

    # Total versements
    total_versements = Versement
      .joins(:produits)
      .where(created_at: cloture.date.beginning_of_month..cloture.date.end_of_month)
      .sum("produits_versements.quantite * produits_versements.montant_unitaire")

    ventes_du_mois = Vente.includes(ventes_produits: :produit)
      .where(date_vente: cloture.date.beginning_of_month..cloture.date.end_of_month)

    total_articles = ventes_du_mois.sum { |v| v.ventes_produits.sum(&:quantite) }

    if cloture.categorie == "mensuelle"
      data = OpenStruct.new(
        categorie: "mensuelle",
        date: cloture.date,
        ouverture: cloture.date.beginning_of_month,
        total_ventes: cloture.total_ventes,
        total_articles: total_articles,
        total_clients: cloture.total_clients,
        ticket_moyen: cloture.ticket_moyen,
        total_cb: cloture.total_cb,
        total_amex: cloture.total_amex,
        total_especes: cloture.total_especes,
        total_cheque: cloture.total_cheque,
        total_encaisse: cloture.total_encaisse,
        ht_0: cloture.ht_0,
        ht_20: cloture.ht_20,
        ttc_0: cloture.ttc_0,
        ttc_20: cloture.ttc_20,
        tva_20: cloture.tva_20,
        total_ht: cloture.total_ht,
        total_tva: cloture.total_tva,
        total_ttc: cloture.total_ttc,
        total_remises: cloture.total_remises,
        total_annulations: cloture.total_annulations,
        total_versements: total_versements,
        details_ventes: [],
        details_versements: []
      )
    else
      # Recalculer à partir des ventes du jour
      ventes = Vente.includes(:client, ventes_produits: :produit).where(date_vente: cloture.date.all_day)

      total_ventes = ventes.count
      total_clients = ventes.map(&:client_id).compact.uniq.size
      total_articles = ventes.sum { |v| v.ventes_produits.sum(&:quantite) }

      total_cb      = ventes.where(mode_paiement: "CB").sum(&:total_net)
      total_amex    = ventes.where(mode_paiement: "AMEX").sum(&:total_net)
      total_especes = ventes.where(mode_paiement: "Espèces").sum(&:total_net)
      total_cheque  = ventes.where(mode_paiement: "Chèque").sum(&:total_net)
      total_encaisse = total_cb + total_amex + total_especes + total_cheque

      ht_0 = ttc_0 = ht_20 = ttc_20 = total_remises = 0

      ventes.each do |vente|
        vente.ventes_produits.each do |vp|
          prix_unitaire = vp.prix_unitaire.to_f > 0 ? vp.prix_unitaire : vp.produit.prix
          remise = vp.remise.to_f
          montant = prix_unitaire * vp.quantite * (1 - remise / 100.0)
          total_remises += prix_unitaire * vp.quantite * (remise / 100.0)

          if vp.produit.etat == "neuf"
            ttc_20 += montant
          else
            ttc_0 += montant
          end
        end
      end

      ht_20  = (ttc_20 / 1.2).round(2)
      tva_20 = (ttc_20 - ht_20).round(2)
      ht_0   = ttc_0
      total_ht  = (ht_0 + ht_20).round(2)
      total_tva = tva_20
      total_ttc = (ttc_0 + ttc_20).round(2)
      ticket_moyen = total_ventes.positive? ? (total_ttc / total_ventes).round(2) : 0

      total_annulations = 0

      jour = Time.zone.today

      # Fond de caisse initial = fond laissé la veille
      cloture_hier = Cloture.where(categorie: "journalier").where("date < ?", Date.today).order(date: :desc).first
      puts "Fond initial d’hier : #{cloture_hier&.fond_caisse_final}"

      entrees = MouvementEspece.where(date: cloture.date, sens: "entrée").sum(:montant)
      sorties = MouvementEspece.where(date: cloture.date, sens: "sortie").sum(:montant)
      total_versements = Versement.where(methode_paiement: "Espèces", created_at: cloture.date.all_day).sum(:montant)


      puts "Entrées : #{entrees} / Sorties : #{sorties} / Versements : #{total_versements}"

      fond_initial = cloture_hier&.fond_caisse_final.to_f
      fond_theorique = fond_initial + entrees - sorties - total_versements
      puts "Fond théorique : #{fond_theorique}"

      data = OpenStruct.new(
        categorie: "journalier",
        date: cloture.date,
        ouverture: ventes.minimum(:created_at),
        total_ventes: total_ventes,
        total_clients: total_clients,
        total_articles: total_articles,
        ticket_moyen: ticket_moyen,
        total_cb: total_cb,
        total_amex: total_amex,
        total_especes: total_especes,
        total_cheque: total_cheque,
        total_encaisse: total_encaisse,
        ht_0: ht_0,
        ht_20: ht_20,
        ttc_0: ttc_0,
        ttc_20: ttc_20,
        tva_20: tva_20,
        total_ht: total_ht,
        total_tva: total_tva,
        total_ttc: total_ttc,
        total_remises: cloture.total_remises,
        total_annulations: cloture.total_annulations,
        fond_caisse_initial: cloture.fond_caisse_initial,
        fond_caisse_final: cloture.fond_caisse_final,
        total_versements: total_versements,
        details_ventes: ventes.flat_map do |vente|
          vente.ventes_produits.map do |vp|
            produit = vp.produit
            prix_unitaire = vp.prix_unitaire.to_f > 0 ? vp.prix_unitaire : produit.prix
            remise = vp.remise.to_f
            montant_total = (prix_unitaire * vp.quantite * (1 - remise / 100)).round(2)

            {
              heure: vente.date_vente.strftime("%H:%M"),
              nom: produit.nom.truncate(25),
              etat: produit.etat.capitalize,
              paiement: vente.mode_paiement,
              quantite: vp.quantite,
              prix_unitaire: prix_unitaire,
              remise: remise,
              montant_total: montant_total
            }
          end
        end,
        details_versements: Versement.includes(client: {}, ventes: { ventes_produits: :produit })
        .where(created_at: cloture.date.all_day)
        .map do |versement|
          produits = versement.ventes.flat_map(&:ventes_produits).map(&:produit)
          produits_client = produits.select { |p| p.client_id == versement.client_id }

          {
            heure: versement.created_at.strftime("%H:%M"),
            client: "#{versement.client.nom} #{versement.client.prenom}",
            montant: versement.montant,
            numero_recu: versement.numero_recu,
            produits: produits_client.group_by(&:id).map do |_, ps|
              produit = ps.first
              quantite = versement.ventes.sum do |vente|
                vente.ventes_produits.where(produit_id: produit.id).sum(:quantite)
              end

              {
                nom: produit.nom.truncate(25),
                etat: produit.etat.capitalize,
                quantite: quantite,
                total: (quantite * produit.prix_deposant).round(2)
              }
            end

          }
      end
      )
    end

    @ticket_z = cloture_ticket_texte(data)
  end


  private


  ##
  # Génère le contenu texte du ticket de clôture à imprimer (Z ou mensuelle).
  #
  # @param [OpenStruct] data Données complètes sur la clôture à afficher
  # @return [String] Texte formaté à imprimer
  def cloture_ticket_texte(data)
    largeur = 42
    lignes = []

    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "3bis rue Notre-Dame".center(largeur)
    lignes << "17200 Royan".center(largeur)
    lignes << "SIRET : 832 259 837 00031".center(largeur)
    titre = data.categorie == "mensuelle" ? "Clôture mensuelle" : "Clôture de caisse Z"
    lignes << titre.center(largeur)
    lignes << I18n.l(data.date, format: :long).center(largeur)
    lignes << "-" * largeur

    # 2️⃣ Dates
    # lignes << "Impression : #{I18n.l(Time.current, format: :default)}"
    lignes << "Ouverture : #{I18n.l(data.ouverture || data.date.beginning_of_day, format: :long)}"
    lignes << "Clôture   : #{I18n.l(data.date, format: :long)} à 20:00"

    lignes << "-" * largeur

    # 3️⃣ Statistiques générales
    lignes << "STATISTIQUES"
    lignes << "Nombre de ventes           : #{data.total_ventes.to_i}"
    lignes << "Nombre d'article vendu     : #{data.total_articles.to_i}"
    lignes << "Nombre de nouveaux clients : #{data.total_clients.to_i}"
    lignes << "Ticket moyen               : #{format('%.2f €', data.ticket_moyen)}"
    lignes << "-" * largeur

    # 4️⃣ Paiements
    lignes << "PAIEMENTS"
    lignes << "AMEX           : #{format('%.2f €', data.total_amex)}"
    lignes << "CB             : #{format('%.2f €', data.total_cb)}"
    lignes << "Espèces        : #{format('%.2f €', data.total_especes)}"
    lignes << "Chèque         : #{format('%.2f €', data.total_cheque)}"
    lignes << "Total encaissé : #{format('%.2f €', data.total_encaisse)}"
    lignes << "-" * largeur

    # 5️⃣ TVA
    lignes << "RECAPITULATIF TVA"
    lignes << format("%-8s%-10s%-10s%-10s", "Taux", "HT", "TVA", "TTC")
    lignes << format("%-8s%-10s%-10s%-10s", "0%", format("%.2f €", data.ht_0), "0.00 €", format("%.2f €", data.ttc_0))
    lignes << format("%-8s%-10s%-10s%-10s", "20%", format("%.2f €", data.ht_20), format("%.2f €", data.tva_20), format("%.2f €", data.ttc_20))
    lignes << "-" * largeur

    # 6️⃣ Totaux
    lignes << "CHIFFRE D'AFFAIRES"
    lignes << format("Total HT   : %.2f €", data.total_ht)
    lignes << format("Total TVA  : %.2f €", data.total_tva)
    lignes << format("Total TTC  : %.2f €", data.total_ttc)
    lignes << "-" * largeur

    # 7️⃣ Divers
    lignes << "REMISES ET ANNULATIONS"
    lignes << "Total remises         : #{format('%.2f €', data.total_remises)}"
    lignes << "Total annulations     : #{format('%.2f €', data.total_annulations)}"
    lignes << "-" * largeur

    unless data.categorie == "mensuelle"
      # Fond théorique
      fond_theorique = data.fond_caisse_initial.to_f +
                   MouvementEspece.where(date: data.date, sens: "entrée").sum(:montant).to_f -
                   MouvementEspece.where(date: data.date, sens: "sortie").sum(:montant).to_f -
                   data.total_versements.to_f

      # Différence affichée
      difference = data.fond_caisse_final.to_f - fond_theorique


      # Divers suite
      lignes << "FOND DE CAISSE"
      lignes << "Initial        : #{format('%.2f €', data.fond_caisse_initial.to_f)}"
      lignes << "Théorique     : #{format('%.2f €', fond_theorique)}"
      lignes << "Final (compté) : #{format('%.2f €', data.fond_caisse_final.to_f)}"
      lignes << "Différence     : #{format('%+.2f €', difference)}"
      lignes << "-" * largeur
    end

    # Versements
    lignes << "VERSEMENTS AUX DEPOSANTS"
    lignes << ""
    lignes << "Total versé : #{format('%.2f €', data.total_versements.to_f)}"
    lignes << "-" * largeur

    # 8️⃣ Détail des ventes
    lignes << "DETAIL DES VENTES"
    lignes << ""

    data.details_ventes.each do |ligne|
      lignes << "#{ligne[:heure]} - #{ligne[:nom]}"
      lignes << "  #{ligne[:etat]} - x#{ligne[:quantite]} à #{sprintf('%.2f €', ligne[:prix_unitaire])}"

      if ligne[:remise].to_f > 0
        montant_remise = (ligne[:prix_unitaire] * ligne[:quantite] * ligne[:remise] / 100.0).round(2)
        lignes << "  Remise : -#{sprintf('%.2f €', montant_remise)} (#{sprintf('%.0f', ligne[:remise])} %)"
      end

      lignes << "  Total : #{sprintf('%.2f €', ligne[:montant_total])} - payé en #{ligne[:paiement]}"
      lignes << "-" * largeur
    end


    # 9️⃣ Détail des versements
    lignes << "DETAIL DES VERSEMENTS"
    lignes << ""
    data.details_versements.each do |v|
      lignes << "#{v[:heure]} - Reçu: #{v[:numero_recu]}"
      lignes << "#{v[:client]}"
      lignes << "Montant : #{format('%.2f €', v[:montant])}"
      lignes << "Produits de la déposante :"
      v[:produits].each do |p|
        ligne_produit = "  - #{p[:nom].ljust(18)} x#{p[:quantite].to_s.ljust(2)} = #{format('%.2f €', p[:total])}"
        lignes << ligne_produit
      end
      lignes << ""
    end
    lignes << "-" * largeur

    # 10 Clôture
    lignes << ""
    lignes << "Merci et à demain !".center(largeur)
    lignes << "\n" * 10

    lignes.join("\n")
  end
end
