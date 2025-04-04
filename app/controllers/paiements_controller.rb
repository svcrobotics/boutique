class PaiementsController < ApplicationController
  before_action :set_client, only: [ :new, :create ]

  def index
    if params[:client_id]
      @client = Client.find(params[:client_id])
      @paiements = @client.paiements.includes(:client).order(date_paiement: :desc)
      @versements = @client.versements.order(created_at: :desc)
    else
      @paiements = Paiement.includes(:client).order(date_paiement: :desc)
      @versements = Versement.includes(:client).order(created_at: :desc)
    end

    @paiements_en_attente = paiements_en_attente
  end


  def new
    @client = Client.find(params[:client_id])

    produits_en_attente = @client.produits.includes(ventes: :paiements).select do |produit|
      produit.en_depot? &&
        produit.ventes.any? &&
        produit.ventes.all? { |vente| vente.paiements.empty? }
    end

    montant_total = produits_en_attente.sum(&:prix_deposant)

    @paiement = Paiement.new(
      client: @client,
      montant: montant_total,
      date_paiement: Date.today
    )
  end

  def create
    @paiement = @client.paiements.build(paiement_params)
    @paiement.date_paiement = Date.today
    @paiement.montant = montant_a_verser(@client)
    @paiement.effectue = true

    if @paiement.save
      @paiement.lier_aux_ventes_du_deposant_et_calculer_montant
      @paiement.reload
      imprimer_paiement(@paiement)

      respond_to do |format|
        format.html { redirect_to client_path(@client), notice: "Paiement effectué avec succès." }
        format.turbo_stream
      end
    else
      render :new
    end
  end

  def show
    @paiement = Paiement.find(params[:id])
  end


  def imprimer
    paiement = Paiement.find(params[:id])
    imprimer_paiement(paiement)
    redirect_to client_path(paiement.client), notice: "Reçu imprimé avec succès"
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def paiement_params
    params.require(:paiement).permit(:methode_paiement, :montant, :date_paiement, :numero_recu)
  end

  def montant_a_verser(client)
    produits_non_payes(client).sum(&:prix_deposant)
  end


  def produits_non_payes(client)
    client.produits.select(&:impaye?)
  end

  def generer_recu_texte(paiement)
    largeur = 42
    lignes = []
    client = paiement.client
    produits = produits_payes_par(paiement)

    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "3bis rue Notre Dame".center(largeur)
    lignes << "17200 Royan".center(largeur)
    lignes << "Tel: 0546778080".center(largeur)
    lignes << "-" * largeur
    lignes << "*** RECU PAIEMENT DEPOT ***".center(largeur)
    lignes << "-" * largeur
    lignes << "Reçu n°#{paiement.numero_recu}"
    lignes << "Date : #{paiement.date_paiement.strftime('%d/%m/%Y')}"
    lignes << "Client : #{client.nom} #{client.prenom}"
    lignes << "Méthode : #{paiement.methode_paiement}"
    lignes << "-" * largeur
    lignes << "Produits payés :"
    lignes << "-" * largeur

    total = 0

    produits.each do |produit|
      nom = produit.nom.truncate(largeur)
      montant = sprintf("%.2f €", produit.prix_deposant)
      lignes << nom
      lignes << " " * (largeur - montant.length) + montant
      lignes << "-" * largeur
      total += produit.prix_deposant
    end

    lignes << "TOTAL PAYE :".ljust(largeur - 12) + sprintf("%.2f €", total).rjust(12)
    lignes << "-" * largeur
    lignes << "Merci pour votre dépôt !".center(largeur)
    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "\n" * 10
    lignes.join("\n")
  end

  def produits_payes_par(paiement)
    paiement.ventes.flat_map(&:ventes_produits).map(&:produit).select do |produit|
      produit.en_depot? && produit.vendu? && produit.client == paiement.client
    end.uniq
  end

  def encode_with_iconv(text)
    tmp_input = Rails.root.join("tmp", "ticket_utf8.txt")
    tmp_output = Rails.root.join("tmp", "ticket_cp858.txt")
    File.write(tmp_input, text)
    system("iconv -f UTF-8 -t CP858 #{tmp_input} -o #{tmp_output}")
    tmp_output
  end

  def imprimer_paiement(paiement)
    texte = generer_recu_texte(paiement)
    fichier = encode_with_iconv(texte)
    system("lp", "-d", "ticket", fichier.to_s)
  end
end
