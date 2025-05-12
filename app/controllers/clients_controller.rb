# ClientsController
# Contrôleur de gestion des clients, incluant la création, modification, suppression,
# recherche, export PDF et affichage de la liste avec pagination.
class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  # GET /clients
  # Affiche la liste des clients triés par nom et prénom.
  # Permet la recherche par nom, prénom, téléphone ou ancien ID.
  # Utilise Pagy pour la pagination si des résultats sont trouvés.
  def index
    @clients = Client.order(nom: :asc, prenom: :asc)

    if params[:query].present?
      search_term = "%#{params[:query]}%"
      @clients = @clients.where("LOWER(nom) LIKE LOWER(?) OR LOWER(prenom) LIKE LOWER(?) OR telephone LIKE ? OR ancien_id LIKE ?",
                                search_term, search_term, search_term, search_term)
    end

    @pagy, @clients = pagy(@clients) if @clients.any?

    respond_to do |format|
      format.html
    end
  end

  # GET /clients/:id
  # Affiche les informations d'un client ainsi que ses paiements en attente.
  def show
    @client = Client.find(params[:id])
    @paiements_en_attente = PaiementsController.new.send(:paiements_en_attente).select { |p| p[:client] == @client }
  end


  # GET /clients/new
  # Affiche le formulaire de création d'un nouveau client.
  # Gère un paramètre optionnel :retour pour savoir si le formulaire a été appelé depuis les ventes.
  def new
    @client = Client.new
    @retour = params[:retour]
  end

  # POST /clients
  # Crée un nouveau client.
  # Redirige vers les ventes si l'appel vient de l'encaissement.
  def create
    @client = Client.new(client_params)
    @retour = params[:retour]

    if @client.save
      if @retour == "ventes"
        redirect_to new_vente_path(client_nom: @client.nom), notice: "Client créée avec succès."
      else
        redirect_to clients_path, notice: "Client ajoutée."
      end
    end
  end

  # GET /clients/:id/edit
  # Affiche le formulaire d'édition du client.
  def edit
  end

  # PATCH/PUT /clients/:id
  # Met à jour les informations d'un client.
  # Redirige vers l'index des clients avec un message de succès ou d'erreur.
  def update
    if @client.update(client_params)
      flash[:notice] = "Client mis à jour avec succès."
      redirect_to clients_path
    else
      flash[:alert] = "Erreur lors de la mise à jour du client."
      render :edit
    end
  end

  # DELETE /clients/:id
  # Supprime un client s'il n'y a pas de contrainte bloquante.
  def destroy
    if @client.destroy
      flash[:notice] = "Client supprimé avec succès."
    else
      flash[:alert] = "Impossible de supprimer le client."
    end
    redirect_to clients_path
  end

  # GET /clients/:id/generate_pdf
  # Génère un fichier PDF avec le récapitulatif des produits en dépôt du client, leur statut et paiements.
  # Utilise la gem Prawn pour la génération du PDF.

  def generate_pdf
    @client = Client.find(params[:id])
    produits = @client.produits.includes(:ventes_produits, :ventes, :produits_versements)

    font_path = Rails.root.join("app/assets/fonts")

    pdf = Prawn::Document.new(
      page_size: "A4",
      margin: [ 20, 20, 20, 20 ]  # [haut, droite, bas, gauche]
    )

    pdf.font_families.update(
      "DejaVuSans" => {
        normal: "#{font_path}/DejaVuSans.ttf"
      }
    )
    pdf.font "DejaVuSans"

    pdf.text "Récapitulatif des Produits en Dépôt", size: 20, align: :center
    pdf.move_down 20
    pdf.text "Nom du client : #{@client.nom} #{@client.prenom}", size: 14
    pdf.text "Email : #{@client.email}", size: 12
    pdf.text "Téléphone : #{@client.telephone}", size: 12
    pdf.text "Date du jour : #{Date.today.strftime('%d/%m/%Y')}", size: 12
    pdf.move_down 10

    data = [ [ "Article", "Prix demandé", "Statut", "Date de dépôt", "Date de paiement", "Reçu", "Code-barres" ] ]

    total_verse = 0.0
    total_lignes = 0

    produits.each do |produit|
      code_barre = produit.code_barre || "N/A"
      total_deposes = produit.stock || 1

      ventes = produit.ventes_produits.includes(:vente).map do |vp|
        vente = vp.vente
        next unless vente
        {
          quantite: vp.quantite || 1,
          vente: vente
        }
      end.compact

      total_vendus = ventes.sum { |v| v[:quantite] }
      restants = total_deposes - total_vendus

      ventes.each do |entry|
        entry[:quantite].times do
          vente = entry[:vente]

          produit_versement = produit.produits_versements.find_by(vente_id: vente.id)
          versement = produit_versement&.versement

          if versement.present?
            statut = "✔️ Vendu et payé"
            date_versement = versement.created_at&.strftime("%d/%m/%Y") || "N/A"
            numero_recu = versement.numero_recu.presence || "N/A"
            total_verse += produit.prix_deposant.to_f
            total_lignes += 1
          else
            statut = "✔️ Vendu (non payé)"
            date_versement = "N/A"
            numero_recu = "N/A"
          end

          data << [
            produit.nom,
            "#{produit.prix_deposant} €",
            statut,
            produit.date_depot&.strftime("%d/%m/%Y") || "N/A",
            date_versement,
            numero_recu,
            code_barre
          ]
        end
      end

      # Lignes pour les exemplaires non vendus
      restants.times do
        data << [
          produit.nom,
          "#{produit.prix_deposant} €",
          "❌ Non vendu",
          produit.date_depot&.strftime("%d/%m/%Y") || "N/A",
          "N/A",
          "N/A",
          code_barre
        ]
      end
    end

    column_widths = {
      0 => 100,   # Article
      1 => 55,   # Prix demandé
      2 => 110,   # Statut
      3 => 65,   # Date de dépôt
      4 => 65,   # Date de paiement
      5 => 110,  # Reçu
      6 => 50    # Code-barres
    }

    pdf.table(data, header: true, column_widths: column_widths, cell_style: { size: 9 }) do
      cells.padding = 5
      row(0).background_color = "eeeeee"
      row(0).font_style = :normal
    end


    pdf.move_down 20
    pdf.text "Total des ventes réglées : #{total_lignes} article(s)", size: 12
    pdf.text "Total versé à la cliente : #{sprintf('%.2f', total_verse)} €", size: 12

    send_data pdf.render, filename: "recapitulatif_produits_#{@client.id}.pdf", type: "application/pdf", disposition: "inline"
  end


  private

  # Méthode privée pour retrouver un client via son ID (utilisée en before_action).
  def set_client
    @client = Client.find(params[:id])
  end

  # Strong parameters pour la création ou mise à jour d'un client.
  def client_params
    params.require(:client).permit(:nom, :prenom, :email, :telephone, :deposant, :ancien_id)
  end
end
