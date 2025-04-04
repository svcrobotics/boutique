class CloturesController < ApplicationController
  require "ostruct"
  def index
    @clotures = Cloture.order(date: :desc)
  end

  def show
    @cloture = Cloture.find(params[:id])
    ventes = Vente.includes(ventes_produits: :produit).where(date_vente: @cloture.date.all_day)

    @ventes_count = ventes.count
    @articles_count = ventes.sum { |v| v.ventes_produits.sum(&:quantite) }

    @total_cb = ventes.where(mode_paiement: "Carte bancaire").sum(:total)
    @total_especes = ventes.where(mode_paiement: "Espèces").sum(:total)
    @total_cheque = ventes.where(mode_paiement: "Chèque").sum(:total)

    @ttc_0 = @ttc_20 = 0

    ventes.each do |vente|
      vente.ventes_produits.each do |vp|
        total = vp.prix_unitaire * vp.quantite
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
  end

  def cloture_mensuelle
    mois = params[:mois]

    begin
      date = Date.parse("#{mois}-01")
    rescue ArgumentError
      redirect_to clotures_path, alert: "❌ Format de date invalide. Utilise AAAA-MM."
      return
    end

    if Cloture.exists?(date: date, categorie: "mensuelle")
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
    total_versements = Versement.where(created_at: date.beginning_of_month..date.end_of_month).sum(:montant)

    # Création en base
    cloture = Cloture.create!(
      categorie: "mensuelle",
      date: date,
      total_ht: clotures_jour.sum(:total_ht),
      total_tva: clotures_jour.sum(:total_tva),
      total_ttc: clotures_jour.sum(:total_ttc),
      total_versements: clotures_jour.sum(:total_versements),
      total_cb: clotures_jour.sum(:total_cb),
      total_amex: clotures_jour.sum(:total_amex),
      total_especes: clotures_jour.sum(:total_especes),
      total_cheque: clotures_jour.sum(:total_cheque),
      total_encaisse: clotures_jour.sum(:total_encaisse),
      total_ventes: clotures_jour.sum(:total_ventes),
      total_clients: clotures_jour.sum(:total_clients),
      total_articles: clotures_jour.sum(:total_articles),
      ticket_moyen: clotures_jour.average(:ticket_moyen).to_f.round(2),
      ht_0: clotures_jour.sum(:ht_0),
      ht_20: clotures_jour.sum(:ht_20),
      ttc_0: clotures_jour.sum(:ttc_0),
      ttc_20: clotures_jour.sum(:ttc_20),
      tva_20: clotures_jour.sum(:tva_20),
      total_remises: clotures_jour.sum(:total_remises),
      total_annulations: clotures_jour.sum(:total_annulations),
      fond_caisse_initial: clotures_jour.sum(:fond_caisse_initial),
      fond_caisse_final: clotures_jour.sum(:fond_caisse_final)
    )

    # OpenStruct pour impression
    data = OpenStruct.new(
      categorie: "mensuelle",
      date: date.end_of_month,
      ouverture: date.beginning_of_month,
      total_ht: cloture.total_ht,
      total_tva: cloture.total_tva,
      total_ttc: cloture.total_ttc,
      total_versements: cloture.total_versements,
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
      fond_caisse_initial: cloture.fond_caisse_initial,
      fond_caisse_final: cloture.fond_caisse_final,
      details_ventes: [],
      details_versements: []
    )

    # Impression
    path_utf8 = Rails.root.join("tmp", "z_ticket_mensuel.txt")
    path_cp   = Rails.root.join("tmp", "z_ticket_mensuel_cp858.txt")

    File.write(path_utf8, cloture_ticket_texte(data))
    system("iconv -f UTF-8 -t CP858 #{path_utf8} -o #{path_cp}")
    system("lp -d ticket #{path_cp}")

    redirect_to clotures_path, notice: "✅ Clôture mensuelle de #{mois} enregistrée et imprimée."
  end



  def imprimer
    cloture = Cloture.find(params[:id])

    # Si c’est une clôture mensuelle, pas besoin de recalculer à partir des ventes
    if cloture.categorie == "mensuelle"
      data = OpenStruct.new(
        categorie: "mensuelle",
        date: cloture.date,
        ouverture: cloture.date.beginning_of_month,
        total_ventes: cloture.total_ventes,
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
        fond_caisse_initial: cloture.fond_caisse_initial,
        fond_caisse_final: cloture.fond_caisse_final,
        total_versements: cloture.total_versements || 0,
        details_ventes: [],
        details_versements: []
      )
    else
      # Clôture journalière : on recalcule à partir des ventes du jour
      ventes = Vente.includes(ventes_produits: :produit).where(date_vente: cloture.date.all_day)

      total_ventes = ventes.count
      total_clients = ventes.map(&:client_id).uniq.compact.count
      ticket_moyen = ventes.sum(&:total).to_f / total_ventes rescue 0

      total_cb = ventes.where(mode_paiement: "Carte bancaire").sum(:total)
      total_amex = ventes.where(mode_paiement: "AMEX").sum(:total)
      total_especes = ventes.where(mode_paiement: "Espèces").sum(:total)
      total_cheque = ventes.where(mode_paiement: "Chèque").sum(:total)
      total_encaisse = total_cb + total_amex + total_especes + total_cheque

      ttc_0 = ttc_20 = 0
      ventes.each do |vente|
        vente.ventes_produits.each do |vp|
          total = vp.prix_unitaire * vp.quantite
          vp.produit.etat == "neuf" ? ttc_20 += total : ttc_0 += total
        end
      end

      ht_20 = (ttc_20 / 1.2).round(2)
      tva_20 = (ttc_20 - ht_20).round(2)
      ht_0 = ttc_0

      data = OpenStruct.new(
        categorie: "journalier",
        date: cloture.date,
        ouverture: cloture.created_at,
        total_ventes: total_ventes,
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
        details_ventes: [],
        details_versements: []
      )
    end

    # Impression
    texte = cloture_ticket_texte(data)

    path_utf8 = Rails.root.join("tmp", "z_ticket.txt")
    path_cp   = Rails.root.join("tmp", "z_ticket_cp858.txt")

    File.write(path_utf8, texte)
    system("iconv -f UTF-8 -t CP858 #{path_utf8} -o #{path_cp}")
    system("lp -d ticket #{path_cp}")

    redirect_to clotures_path, notice: "🖨️ Clôture imprimée avec succès."
  end


  def cloture_z
    jour = params[:date].present? ? Date.parse(params[:date]) : Date.current

    return redirect_to ventes_path, alert: "Clôture déjà effectuée pour aujourd’hui." if Cloture.exists?(date: jour, categorie: "journalier")

    ventes = Vente.includes(:client, ventes_produits: :produit).where(date_vente: jour.all_day)
    return redirect_to ventes_path, alert: "Aucune vente pour aujourd’hui." if ventes.empty?

    total_ventes = ventes.count
    total_clients = ventes.map(&:client_id).compact.uniq.size
    total_articles = ventes.sum { |v| v.ventes_produits.sum(&:quantite) }
    total_ttc = ventes.sum(&:total)

    ticket_moyen = total_ventes.positive? ? (total_ttc / total_ventes).round(2) : 0

    total_cb      = ventes.where(mode_paiement: "Carte bancaire").sum(&:total)
    total_amex    = ventes.where(mode_paiement: "Amex").sum(&:total)
    total_especes = ventes.where(mode_paiement: "Espèces").sum(&:total)
    total_cheque  = ventes.where(mode_paiement: "Chèque").sum(&:total)
    total_encaisse = total_cb + total_especes + total_cheque + total_amex

    ht_0 = ttc_0 = ht_20 = ttc_20 = 0
    ventes.each do |vente|
      vente.ventes_produits.each do |vp|
        montant = vp.prix_unitaire * vp.quantite
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

    # TODO: ajuster ces valeurs une fois le système d’annulation/remise/fond mis en place
    total_remises     = 0
    total_annulations = 0
    fond_caisse_initial = 0
    fond_caisse_final   = total_especes

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
      total_remises: total_remises,
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
      total_remises: total_remises,
      total_annulations: total_annulations,
      fond_caisse_initial: fond_caisse_initial,
      fond_caisse_final: fond_caisse_final,
      total_versements: total_versements,
      details_ventes: ventes.flat_map do |vente|
        vente.ventes_produits.map do |vp|
          produit = vp.produit
          {
            heure: vente.date_vente.strftime("%H:%M"),
            nom: produit.nom.truncate(25),
            etat: produit.etat.capitalize,
            paiement: vente.mode_paiement,
            prix: vp.prix_unitaire.to_f > 0 ? vp.prix_unitaire : produit.prix
          }
        end
      end,
      details_versements: Versement.includes(ventes: { ventes_produits: :produit }, client: {})
        .where(created_at: jour.all_day)
        .flat_map do |versement|
          versement.ventes.flat_map do |vente|
            vente.ventes_produits.map do |vp|
              produit = vp.produit
              {
                heure: versement.created_at.strftime("%H:%M"),
                nom: produit.nom.truncate(25),
                etat: produit.etat.capitalize,
                paiement: "Versement à #{versement.client.nom} #{versement.client.prenom}",
                versement: versement.montant,
                recu: versement.numero_recu
              }
            end
          end
        end
    )

    texte = cloture_ticket_texte(data)

    File.write(Rails.root.join("tmp/z_ticket.txt"), texte)
    system("iconv -f UTF-8 -t CP858 tmp/z_ticket.txt -o tmp/z_ticket_cp858.txt")
    system("lp -d ticket tmp/z_ticket_cp858.txt")

    redirect_to clotures_path, notice: "✅ Ticket Z imprimé avec succès."
  end

  private


  def cloture_ticket_texte(data)
    largeur = 42
    lignes = []

    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "3bis rue Notre-Dame".center(largeur)
    lignes << "17200 Royan".center(largeur)
    lignes << "N° SIRET: ".center(largeur)
    titre = data.categorie == "mensuelle" ? "Clôture mensuelle" : "Clôture de caisse Z"
    lignes << titre.center(largeur)
    lignes << I18n.l(data.date, format: :long).center(largeur)
    lignes << "-" * largeur

    # 2️⃣ Dates
    # lignes << "Impression : #{I18n.l(Time.current, format: :default)}"
    lignes << "Ouverture : #{I18n.l(data.ouverture || data.date.beginning_of_day, format: :long)}"
    lignes << "Clôture   : #{I18n.l(data.date.end_of_month.end_of_day, format: :long)}"

    lignes << "-" * largeur

    # 3️⃣ Statistiques générales
    lignes << "Statistiques"
    lignes << "Nombre de ventes : #{data.total_ventes}"
    lignes << "Nombre d'article vendu : #{data.total_articles}"
    lignes << "Nombre de clients enregistrer : #{data.total_clients}"
    lignes << "Ticket moyen : #{format('%.2f €', data.ticket_moyen)}"
    lignes << "-" * largeur

    # 4️⃣ Paiements
    lignes << "Paiements"
    lignes << "AMEX           : #{format('%.2f €', data.total_amex)}"
    lignes << "CB             : #{format('%.2f €', data.total_cb)}"
    lignes << "Espèces        : #{format('%.2f €', data.total_especes)}"
    lignes << "Chèque         : #{format('%.2f €', data.total_cheque)}"
    lignes << "Total encaissé : #{format('%.2f €', data.total_encaisse)}"
    lignes << "-" * largeur

    # 5️⃣ TVA
    lignes << "Récapitulatif TVA"
    lignes << format("%-8s%-10s%-10s%-10s", "Taux", "HT", "TVA", "TTC")
    lignes << format("%-8s%-10s%-10s%-10s", "0%", format("%.2f €", data.ht_0), "0.00 €", format("%.2f €", data.ttc_0))
    lignes << format("%-8s%-10s%-10s%-10s", "20%", format("%.2f €", data.ht_20), format("%.2f €", data.tva_20), format("%.2f €", data.ttc_20))
    lignes << "-" * largeur

    # 6️⃣ Totaux
    lignes << "TOTAL"
    lignes << format("HT TOTAL   : %.2f €", data.total_ht)
    lignes << format("TVA TOTAL  : %.2f €", data.total_tva)
    lignes << format("TTC TOTAL  : %.2f €", data.total_ttc)
    lignes << "-" * largeur

    # 7️⃣ Divers
    lignes << "Autres infos"
    lignes << "Remises         : #{format('%.2f €', data.total_remises)}"
    lignes << "Annulations     : #{format('%.2f €', data.total_annulations)}"
    lignes << "Fond de caisse  : #{format('%.2f €', data.fond_caisse_initial)}"
    lignes << "Fond final      : #{format('%.2f €', data.fond_caisse_final)}"
    lignes << "Total versements : #{format('%.2f €', data.total_versements.to_f)}"
    lignes << "-" * largeur

    # 8️⃣ Détail des ventes
    lignes << "Détail des ventes"
    data.details_ventes.each do |detail|
      lignes << "#{detail[:heure]} #{detail[:nom].ljust(25)} "
      lignes << "#{detail[:etat]} | #{detail[:paiement]} | #{format('%.2f €', detail[:prix])}"
    end
    lignes << "-" * largeur

    # 9 Détail des versements
    lignes << "Détail des versements"
    data.details_versements.each do |detail|
      lignes << "#{detail[:etat]}"
      lignes << "#{detail[:heure]} #{detail[:nom].ljust(25)}"
      lignes << "#{detail[:paiement]} | #{format('%.2f €', detail[:versement])}"
      lignes << "Reçu :  #{detail[:recu]}"
    end
    lignes << "-" * largeur

    # 10 Clôture
    lignes << ""
    lignes << "Merci et à demain !".center(largeur)
    lignes << "\n" * 10

    lignes.join("\n")
  end
end
