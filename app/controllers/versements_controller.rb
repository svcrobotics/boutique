class VersementsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_client, only: %i[new create]

  def index
    @versements = Versement.includes(:client).order(created_at: :desc)
    @paiements_en_attente = paiements_en_attente
  end

  def new
    @produits_a_payer = {}

    # Pour chaque produit de la cliente
    @client.produits.includes(:ventes).each do |produit|
      next unless produit.en_depot?

      produit.ventes.each do |vente|
        vp = vente.ventes_produits.find_by(produit_id: produit.id)
        next unless vp

        # Calcul des quantités déjà versées pour cette vente + produit
        quantite_vendue = vp.quantite
        quantite_deja_versee = ProduitsVersement.where(produit_id: produit.id, vente_id: vente.id).sum(:quantite)
        quantite_a_verser = quantite_vendue - quantite_deja_versee

        next if quantite_a_verser <= 0

        @produits_a_payer[produit] ||= []
        @produits_a_payer[produit] << {
          vente: vente,
          quantite: quantite_a_verser,
          prix_unitaire: produit.prix_deposant,
          total: produit.prix_deposant * quantite_a_verser
        }
      end
    end

    @total = @produits_a_payer.values.flatten.sum { |ligne| ligne[:total] }

    if @produits_a_payer.empty?
      redirect_to client_path(@client), alert: "Aucun produit à verser pour cette cliente."
    end
  end


  def create
    lignes = params[:lignes] || []

    versement = Versement.new(
      client: @client,
      methode_paiement: params[:methode_paiement] || "Espèces",
      numero_recu: "VR#{Time.now.strftime('%Y%m%d%H%M%S')}"
    )

    total = 0
    ventes_ids = []

    lignes.each do |ligne|
      produit_id = ligne[:produit_id].to_i
      vente_id = ligne[:vente_id].to_i
      quantite = ligne[:quantite].to_i

      produit = Produit.find_by(id: produit_id)
      vente = Vente.find_by(id: vente_id)

      next unless produit && vente
      next unless produit.client == @client
      next unless produit.en_depot?

      montant = produit.prix_deposant * quantite
      total += montant
      ventes_ids << vente.id

      versement.produits_versements.build(
        produit: produit,
        vente_id: vente.id,
        quantite: quantite
      )
    end

    versement.montant = total
    versement.ventes = Vente.where(id: ventes_ids.uniq)

    if versement.save
      imprimer_versement(versement)
      redirect_to client_path(@client), notice: "Versement de #{number_to_currency(total)} effectué avec succès."
    else
      redirect_to new_client_versement_path(@client), alert: "Erreur lors de la création du versement."
    end
  end


  def imprimer
    versement = Versement.find(params[:id])
    imprimer_versement(versement)
    redirect_to client_path(versement.client), notice: "Reçu imprimé avec succès."
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def encode_with_iconv(text)
    tmp_input  = Rails.root.join("tmp", "ticket_utf8.txt")
    tmp_output = Rails.root.join("tmp", "ticket_cp858.txt")
    File.write(tmp_input, text)
    system("iconv -f UTF-8 -t CP858 #{tmp_input} -o #{tmp_output}")
    tmp_output
  end

  def generer_ticket_versement(versement)
    largeur = 42
    lignes = []

    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "3bis rue Notre Dame".center(largeur)
    lignes << "17200 Royan".center(largeur)
    lignes << "Tel: 0546778080".center(largeur)
    lignes << "-" * largeur
    lignes << "*** VERSEMENT ***".center(largeur)
    lignes << "-" * largeur
    lignes << "Reçu n°#{versement.numero_recu}"
    lignes << "Date : #{I18n.l(versement.created_at.to_date)}"
    lignes << "Déposante : #{versement.client.prenom} #{versement.client.nom}"
    lignes << "-" * largeur

    total = 0

    versement.produits_versements.each do |pv|
      produit = pv.produit
      next unless produit.client == versement.client && produit.en_depot?

      nom = produit.nom.truncate(largeur - 10)
      qte = pv.quantite
      montant = produit.prix_deposant * qte

      lignes << "#{nom} x#{qte}"
      lignes << " " * (largeur - 10) + sprintf("%.2f €", montant)
      lignes << "-" * largeur
      total += montant
    end


    lignes << "Total versé : #{sprintf('%.2f €', total)}".rjust(largeur)
    lignes << "Méthode : #{versement.methode_paiement}".rjust(largeur)
    lignes << "-" * largeur
    lignes << "Merci pour votre confiance".center(largeur)
    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "\n" * 10
    lignes.join("\n")
  end

  def imprimer_versement(versement)
    texte = generer_ticket_versement(versement)
    fichier = encode_with_iconv(texte)
    system("lp", "-d", "SEWOO_LKT_Series", fichier.to_s)
  end
end
