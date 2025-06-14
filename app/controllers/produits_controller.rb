class ProduitsController < ApplicationController
  require "prawn"
  require "barby"
  require "barby/barcode/code_128"
  require "barby/outputter/png_outputter"

  before_action :set_produit, only: %i[show edit update destroy]

  def index
    if params[:code_barre].present?
      produit = Produit.find_by(code_barre: params[:code_barre])
      if produit
        render json: { id: produit.id, nom: produit.nom, prix: produit.prix_affiche }
      else
        render json: {}, status: :not_found
      end
      return
    end

    @produits = Produit.includes(:fournisseur, :client).order(updated_at: :desc)

    if params[:query].present?
      @produits = @produits.where(
        "produits.nom LIKE :query OR
         produits.code_fournisseur LIKE :query OR
         produits.code_barre LIKE :query OR
         fournisseurs.nom LIKE :query OR
         clients.nom LIKE :query",
        query: "%#{params[:query]}%"
      ).references(:fournisseur, :client)
    end

    @produits = @produits.where(categorie: params[:categorie]) if params[:categorie].present?
    @produits = @produits.where(etat: params[:etat]) if params[:etat].present?

    if params[:stock] == "disponible"
      @produits = @produits.where("stock > ?", 0)
    elsif params[:stock] == "rupture"
      @produits = @produits.where(stock: 0)
    end

    # Récupération complète des produits filtrés avant pagination
    @produits_globaux = @produits.load

    @pagy, @produits = pagy(@produits)

    respond_to do |format|
      format.html
      format.json { render json: @produits.select(:id, :nom, :prix, :code_barre) }
    end
  end

  require 'open-uri'
  require 'base64'

  def generer_description_ai
    image_url = params[:image_url]
    return render json: { error: "URL manquante" }, status: :unprocessable_entity unless image_url

    # Télécharger l'image depuis le lien Drive (format https://drive.google.com/uc?id=...)
    begin
      image_data = URI.open(image_url).read
    rescue => e
      return render json: { error: "Erreur lors du téléchargement de l'image : #{e.message}" }, status: :bad_request
    end

    # Convertir l'image en base64
    encoded_image = Base64.strict_encode64(image_data)

    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: "Tu es un expert en mode. Tu rédiges des descriptions pour des vêtements à partir de photos. Ignore tout ce qui n'est pas un vêtement."
          },
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "Voici la photo d’un vêtement. Décris-le pour une fiche produit mode."
              },
              {
                type: "image_url",
                image_url: {
                  url: "data:image/jpeg;base64,#{encoded_image}"
                }
              }
            ]
          }
        ],
        temperature: 0.7
      }
    )

    description = response.dig("choices", 0, "message", "content")
    render json: { description: description }
  end



  def photos_url_converter
    raw_links = params[:raw_links].to_s

    @liens_directs = raw_links.split(/[\s,]+/).map do |link|
      if link.include?("drive.google.com")
        if link =~ /id=([\w-]+)/
          "https://drive.google.com/uc?id=#{$1}"
        elsif link =~ %r{/d/([\w-]+)}
          "https://drive.google.com/uc?id=#{$1}"
        else
          nil
        end
      else
        link # Lien inchangé si ce n’est pas un lien Drive
      end
    end.compact

    render :photos_url_converter
  end


  def envoyer_shopify
    produit = Produit.find(params[:id])

    session = ShopifyAPI::Auth::Session.new(
      shop: ENV.fetch("SHOPIFY_HOST_NAME"),
      access_token: ENV.fetch("SHOPIFY_ACCESS_TOKEN")
    )
    client = ShopifyAPI::Clients::Rest::Admin.new(session: session)

    # Préparation des URLs d’images hébergées sur Google Drive
    photo_urls = produit.photos_url.to_s.split(",").map(&:strip)

    shopify_payload = {
      product: {
        title: produit.nom,
        body_html: "<p>#{produit.description}</p>",
        vendor: "Vintage-Royan",
        product_type: produit.categorie || "vêtement",
        tags: [produit.etat, ("neuf" if produit.neuf), ("occasion" if produit.occasion)].compact.join(","),
        variants: [
          {
            price: produit.prix.to_f.to_s,
            sku: produit.code_barre || "SKU-#{produit.id}",
            inventory_quantity: produit.stock || 1
          }
        ],
        images: photo_urls.map { |url| { src: url } }
      }
    }

    if produit.shopify_id.present?
      response = client.put(path: "products/#{produit.shopify_id}", body: shopify_payload)
    else
      response = client.post(path: "products", body: shopify_payload)
      produit.update(shopify_id: response.body["product"]["id"]) if response.body["product"]
    end

    if response.body["product"]
      produit.update(en_ligne: true)
      redirect_to produit, notice: "✅ Produit synchronisé avec Shopify avec images !"
    else
      redirect_to produit, alert: "❌ Erreur Shopify : #{response.body.inspect}"
    end
  end


  def new
    @produit = Produit.new
  end

  def supprimer_photo
    @produit = Produit.find(params[:id])
    photo = @produit.photos.find(params[:photo_id])
    photo.purge
    redirect_to edit_produit_path(@produit), notice: "Photo supprimée."
  end

  def create
    @produit = Produit.new(produit_params)

    if params[:produit][:etat] != "depot_vente"
      @produit.en_depot = false
    end

    if @produit.save
      respond_to do |format|
        format.html { redirect_to @produit, notice: "Produit créé avec succès." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @produit.en_depot = false if params[:produit][:etat] != "depot_vente"

    produit_data = produit_params.dup
    produit_data[:impression_code_barre] = false unless produit_data.key?(:impression_code_barre)

    if @produit.update(produit_data)
      redirect_to @produit, notice: "Produit mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def show
  end

  def edit
  end


  def destroy
    @produit = Produit.find(params[:id])
    @produit.destroy

    respond_to do |format|
      format.html { redirect_to produits_path, notice: "Produit supprimé." }
    end
  end

  def versement_en_attente?
    en_depot? &&
      ventes.exists? &&
      ventes.all? { |v| v.versements.empty? }
  end


  # 🔥 ✅ Méthode pour imprimer UNE SEULE étiquette d’un produit
  def generate_label
    produit = Produit.find_by(id: params[:id])
    if produit.nil?
      return redirect_to produits_path, alert: "Produit introuvable."
    end

    # 📌 Génération du PDF pour une seule étiquette
    pdf = Prawn::Document.new(page_size: [ 162, 91 ], margin: 0)
    add_label_to_pdf(pdf, produit)

    # 📂 Enregistrement et impression
    pdf_path = save_and_print_pdf(pdf, "etiquette_#{produit.id}")

    # ✅ Mise à jour impression_code_barre
    produit.update(impression_code_barre: false)

    redirect_to produits_path, notice: "Étiquette imprimée avec succès !"
  end

  # 🔥 ✅ Méthode pour imprimer PLUSIEURS étiquettes selon le stock
  def generate_multiple_labels
    produits = Produit.where(impression_code_barre: true)
    if produits.empty?
      return redirect_to produits_path, alert: "Aucun produit à imprimer."
    end

    # 📌 Création d'un document PDF unique pour toutes les étiquettes
    pdf = Prawn::Document.new(page_size: [ 162, 91 ], margin: 0)
    first_page = true

    produits.each do |produit|
      next if produit.stock.to_i <= 0
      quantite = produit.stock.to_i

      quantite.times do
        # Utiliser la première page existante pour la première étiquette,
        # puis ajouter une nouvelle page pour les suivantes
        pdf.start_new_page unless first_page
        first_page = false
        add_label_to_pdf(pdf, produit)
      end
    end

    # 📂 Enregistrement et impression
    pdf_path = save_and_print_pdf(pdf, "etiquettes_multiples")

    # ✅ Mise à jour de tous les produits imprimés
    produits.update_all(impression_code_barre: false)

    redirect_to produits_path, notice: "Toutes les étiquettes ont été imprimées !"
  end

  private

  def add_label_to_pdf(pdf, produit)
    label_width = 162
    label_height = 91

    # Configuration de la police
    pdf.font_families.update("DejaVuSans" => { normal: Rails.root.join("app/assets/fonts/DejaVuSans.ttf") })
    pdf.font "DejaVuSans"

    # Création de la zone de l'étiquette
    pdf.bounding_box([ 0, label_height ], width: label_width, height: label_height) do
      pdf.stroke_bounds
      pdf.move_down 10
      pdf.text produit.nom, size: 10, align: :center
      pdf.move_down 0

      if produit.en_promo? && produit.prix_promo.present?
        prix_normal = ActionController::Base.helpers.number_to_currency(produit.prix)
        prix_promo  = ActionController::Base.helpers.number_to_currency(produit.prix_promo)

        pdf.move_down 2

        # Affichage du texte complet (Prix : 89,99 €   50,00 €)
        texte_complet = "Prix : #{prix_normal}   #{prix_promo}"
        y = pdf.cursor
        pdf.text texte_complet, size: 12, align: :center

        # Mesure précise du début du prix_normal dans "Prix : #{prix_normal}"
        prefix      = "Prix : "
        prefix_width = pdf.width_of(prefix, size: 12)
        prix_width   = pdf.width_of(prix_normal, size: 12)
        total_width  = pdf.width_of(texte_complet, size: 12)
        x_offset     = (pdf.bounds.width - total_width) / 2

        x1 = x_offset + prefix_width
        x2 = x1 + prix_width
        y_line = y - 6

        pdf.stroke do
          pdf.line [x1, y_line], [x2, y_line + 6] # oblique seulement sur le prix
        end
      else
        pdf.move_down 2
        prix = ActionController::Base.helpers.number_to_currency(produit.prix)
        pdf.text "Prix : #{prix}", size: 12, style: :normal, align: :center
      end

      pdf.move_down 0

      # Infos spécifiques selon l'état du produit
      case produit.etat
      when "neuf"
        pdf.text "#{produit.fournisseur&.nom} - #{produit.code_fournisseur}", size: 7, align: :center
        pdf.move_down 0
        pdf.text "Neuf - Code-barre: #{produit.code_barre}", size: 7, align: :center
      when "depot_vente"
        ancien_id = produit.client&.ancien_id.presence || "N/A"
        pdf.text "Ancien ID: #{ancien_id}", size: 7, align: :center
        pdf.move_down 0
        pdf.text "Dépôt-Vente - Code-barre: #{produit.code_barre}", size: 7, align: :center
      when "occasion"
        pdf.text "#{produit.fournisseur&.nom}", size: 7, align: :center
        pdf.move_down 0
        pdf.text "Occasion - Code-barre: #{produit.code_barre}", size: 7, align: :center
      end

      # Génération et intégration du code-barres si présent
      if produit.code_barre.present?
        barcode = Barby::Code128.new(produit.code_barre.to_s)
        barcode_img = barcode.to_png(xdim: 2, height: 30)
        barcode_path = Rails.root.join("tmp", "barcode_#{produit.id}.png")
        File.open(barcode_path, "wb") { |f| f.write barcode_img }
        pdf.image barcode_path, width: 120, height: 30, position: :center
      end
    end
  end

  # ✅ 📌 Méthode pour enregistrer et imprimer le PDF
  def save_and_print_pdf(pdf, filename)
    pdf_path = Rails.root.join("tmp", "#{filename}_#{Time.now.to_i}.pdf")
    File.open(pdf_path, "wb") { |f| f.write(pdf.render) }

    # 🖨 Envoi vers l'imprimante Dymo
    # system("lp -d DYMO_LabelWriter_450_Duo_Label #{pdf_path}")
    # system("lp -d LabelWriter-450 #{pdf_path}")
    system("lp -d DYMO_LabelWriter_450 #{pdf_path}")
    # 🗑 Suppression du fichier temporaire après impression
    File.delete(pdf_path) if File.exist?(pdf_path)

    pdf_path
  end


  def set_produit
    @produit = Produit.find(params[:id])
  end

  def produit_params
    params.require(:produit).permit(:code_fournisseur, :code_barre, :impression_code_barre, :etat,
    :vendu, :prix_deposant, :date_depot, :produit_id, :observation, :nom, :description, :prix,
    :prix_achat, :stock, :categorie, :date_achat, :facture, :fournisseur_id, :client_id, :en_depot, :remise_fournisseur, 
    :taux_remise_fournisseur, :en_promo, :prix_promo, :photos_url)
  end
end
