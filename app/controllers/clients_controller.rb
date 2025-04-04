class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = Client.all
    @clients = Client.order(nom: :asc, prenom: :asc)

    if params[:query].present?
      search_term = "%#{params[:query]}%"
      @clients = @clients.where("LOWER(nom) LIKE LOWER(?) OR LOWER(prenom) LIKE LOWER(?) OR telephone LIKE ? OR ancien_id LIKE ?",
                                search_term, search_term, search_term, search_term)
    end

    # Vérifie s'il y a des résultats avant d'utiliser Pagy
    if @clients.any?
      @pagy, @clients = pagy(@clients)
    end

    respond_to do |format|
      format.html
      # format.turbo_stream
    end
  end

  def show
    @client = Client.find(params[:id])
    @paiements_en_attente = paiements_en_attente.select { |p| p[:client] == @client }
  end


  def new
    @client = Client.new
    @retour = params[:retour] # optionnel
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      if params[:retour] == "ventes"
        redirect_to new_vente_path(client_nom: @client.nom), notice: "Cliente créée avec succès."
      else
        redirect_to clients_path, notice: "Cliente ajoutée."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # render layout: false if turbo_frame_request?
  end

  def update
    if @client.update(client_params)
      flash[:notice] = "Client mis à jour avec succès."
      redirect_to clients_path
    else
      flash[:alert] = "Erreur lors de la mise à jour du client."
      render :edit
    end
  end

  def destroy
    @client = Client.find(params[:id])
    if @client.destroy
      flash[:notice] = "Client supprimé avec succès."
    else
      flash[:alert] = "Impossible de supprimer le client."
    end
    redirect_to clients_path
  end

  def generate_pdf
    @client = Client.find(params[:id])
    produits = @client.produits.includes(ventes: [ :versements ])

    pdf = Prawn::Document.new(page_size: "A4")
    font_path = Rails.root.join("app/assets/fonts/DejaVuSans.ttf")
    pdf.font_families.update("DejaVuSans" => { normal: font_path })
    pdf.font "DejaVuSans", style: :normal

    pdf.text "Récapitulatif des Produits en Dépôt", size: 20, align: :center
    pdf.move_down 20
    pdf.text "Nom du client : #{@client.nom} #{@client.prenom}", size: 14
    pdf.text "Email : #{@client.email}", size: 12
    pdf.text "Téléphone : #{@client.telephone}", size: 12
    pdf.text "Date du jour : #{Date.today.strftime('%d/%m/%Y')}", size: 12
    pdf.move_down 10

    data = [ [ "ID", "Article", "Prix demandé", "Statut", "Date de dépôt", "Date de paiement", "Reçu" ] ]

    total_verse = 0.0
    total_lignes = 0

    produits.each do |produit|
      if produit.en_depot? && produit.ventes.any?
        produit.ventes.each do |vente|
          versement = vente.versements.first

          if versement.present?
            numero_recu = versement.numero_recu.presence || "N/A"
            date_versement = versement.created_at&.strftime("%d/%m/%Y") || "N/A"

            data << [
              produit.id,
              produit.nom,
              "#{produit.prix_deposant} €",
              "✔️ Vendu et payé",
              produit.date_depot&.strftime("%d/%m/%Y") || "N/A",
              date_versement,
              numero_recu
            ]

            total_verse += produit.prix_deposant.to_f
            total_lignes += 1
          else
            data << [
              produit.id,
              produit.nom,
              "#{produit.prix_deposant} €",
              "✔️ Vendu (non payé)",
              produit.date_depot&.strftime("%d/%m/%Y") || "N/A",
              "N/A",
              "N/A"
            ]
          end
        end
      else
        data << [
          produit.id,
          produit.nom,
          "#{produit.prix_deposant} €",
          "❌ Non vendu",
          produit.date_depot&.strftime("%d/%m/%Y") || "N/A",
          "N/A",
          "N/A"
        ]
      end
    end

    pdf.table(data, header: true, width: pdf.bounds.width) do
      cells.padding = 5
      self.header = true
    end

    pdf.move_down 20
    pdf.text "Total des ventes réglées : #{total_lignes} article(s)", size: 12
    pdf.text "Total versé à la cliente : #{sprintf('%.2f', total_verse)} €", size: 12

    send_data pdf.render,
              filename: "recapitulatif_produits_#{@client.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end


  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:nom, :prenom, :email, :telephone, :deposant, :ancien_id)
  end
end
