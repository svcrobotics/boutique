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
        render json: { id: produit.id, nom: produit.nom, prix: produit.prix }
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

    @pagy, @produits = pagy(@produits)

    respond_to do |format|
      format.html
      format.json { render json: @produits.select(:id, :nom, :prix, :code_barre) }
    end
  end


  def new
    @produit = Produit.new
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

    # ✅ Corrige le problème de case décochée non envoyée
    produit_data[:impression_code_barre] = false unless produit_data.key?(:impression_code_barre)

    # Gestion des images
    if produit_data[:images].present?
      produit_data[:images].reject!(&:blank?)
      @produit.images.attach(produit_data[:images])
    end

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
      pdf.text produit.nom.capitalize, size: 10, align: :center
      pdf.move_down 0
      pdf.text "Prix: #{produit.prix} EUR", size: 15, align: :center
      pdf.move_down 0

      # Infos spécifiques selon l'état du produit
      case produit.etat
      when "neuf"
        pdf.text "#{produit.fournisseur&.nom} - Code: #{produit.code_fournisseur}", size: 7, align: :center
        pdf.move_down 0
        pdf.text "Neuf - Code Barre: #{produit.code_barre}", size: 7, align: :center
      when "depot_vente"
        pdf.text "Client: #{produit.client&.ancien_id || 'N/A'}", size: 7, align: :center
        pdf.move_down 0
        pdf.text "Dépôt-Vente - Code barre: #{produit.code_barre}", size: 7, align: :center
      when "occasion"
        pdf.text "#{produit.fournisseur&.nom}", size: 7, align: :center
        pdf.move_down 0
        pdf.text "Occasion - C.Barre: #{produit.code_barre}", size: 7, align: :center
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
    system("lp -d DYMO_LabelWriter_450_Duo_Label #{pdf_path}")

    # 🗑 Suppression du fichier temporaire après impression
    File.delete(pdf_path) if File.exist?(pdf_path)

    pdf_path
  end


  def set_produit
    @produit = Produit.find(params[:id])
  end

  def produit_params
    params.require(:produit).permit(:code_fournisseur, :code_barre, :impression_code_barre, :etat, :vendu, :prix_deposant, :date_depot, :produit_id, :observation, :nom, :description, :prix, :prix_achat, :stock, :categorie, :date_achat, :facture, :fournisseur_id, :client_id, :en_depot, images: [])
  end
end
