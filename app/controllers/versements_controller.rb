class VersementsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_client, only: %i[new create]

  def index
    @versements = Versement.includes(:client, :produit, :vente).order(date: :desc)
    @paiements_en_attente = paiements_en_attente
  end

  def new
    @produits = @client.produits.select(&:versement_en_attente?)
    @total = @produits.sum(&:prix_deposant)

    if @produits.empty?
      redirect_to client_path(@client), alert: "Aucun produit à verser pour cette cliente."
    end
  end

  def create
    produits = @client.produits.select(&:versement_en_attente?)

    if produits.empty?
      redirect_to client_path(@client), alert: "Aucun versement à effectuer."
      return
    end

    montant_total = produits.sum(&:prix_deposant)

    versement = Versement.new(
      client: @client,
      montant: montant_total,
      methode_paiement: "Espèces", # à saisir dans le formulaire
      numero_recu: "VR#{Time.now.strftime('%Y%m%d%H%M%S')}"
    )

    # Associer toutes les ventes concernées
    ventes = produits.map(&:ventes).flatten.uniq
    versement.ventes = ventes

    if versement.save
      redirect_to client_path(@client), notice: "Versement de #{number_to_currency(montant_total)} effectué avec succès."
    else
      redirect_to new_client_versement_path(@client), alert: "Erreur lors de la création du versement."
    end
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

    versement.ventes.each do |vente|
      vente.produits.where(client_id: versement.client.id).each do |produit|
        lignes << produit.nom[0..41]
        lignes << "Prix déposant : #{'%.2f €' % produit.prix_deposant}"
        lignes << "-" * largeur
      end
    end

    lignes << "Total versé : #{'%.2f €' % versement.montant}".rjust(largeur)
    lignes << "Méthode : #{versement.methode_paiement}".rjust(largeur)
    lignes << "-" * largeur
    lignes << "Merci pour votre confiance".center(largeur)
    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "\n" * 10 # découpe

    lignes.join("\n")
  end

  def imprimer
    versement = Versement.find(params[:id])
    file_to_print = encode_with_iconv(generer_ticket_versement(versement))
    system("lp", "-d", "ticket", file_to_print.to_s)
    redirect_to client_path(versement.client), notice: "Reçu imprimé avec succès."
  end



  private

  def set_client
    @client = Client.find(params[:client_id])
  end
end
