class AvoirsController < ApplicationController

  def index
    @avoirs = Avoir.order(created_at: :desc).includes(:client, :vente)
  end

  def show
    avoir = Avoir.find(params[:id])

    pdf = Prawn::Document.new
    pdf.text "Avoir n°#{avoir.id}", size: 20, style: :bold
    pdf.move_down 10
    pdf.text "Client : #{avoir.client.nom} #{avoir.client.prenom}"
    pdf.text "Vente annulée : ##{avoir.vente.id}"
    pdf.text "Montant de l’avoir : #{sprintf('%.2f €', avoir.montant)}"
    pdf.text "Date : #{I18n.l(avoir.created_at.to_date)}"
    pdf.text "Valable jusqu’au : #{I18n.l((avoir.created_at + 6.months).to_date)}"
    pdf.move_down 20
    pdf.text "Valable uniquement dans votre boutique."

    send_data pdf.render,
      filename: "avoir_#{avoir.id}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end

  def imprimer
    avoir = Avoir.find(params[:id])
    texte = generer_ticket_avoir(avoir)

    path_utf8 = Rails.root.join("tmp", "avoir_#{avoir.id}.txt")
    path_cp   = Rails.root.join("tmp", "avoir_#{avoir.id}_cp858.txt")

    File.write(path_utf8, texte)
    system("iconv -f UTF-8 -t CP858 #{path_utf8} -o #{path_cp}")
    system("lp", "-d", "SEWOO_LKT_Series", path_cp.to_s)

    redirect_to avoirs_path, notice: "✅ Ticket avoir n°#{avoir.id} imprimé"
  end


  def generer_ticket_avoir(avoir)
    largeur = 42
    lignes = []

    # En-tête boutique
    lignes << "VINTAGE ROYAN".center(largeur)
    lignes << "3bis rue Notre Dame".center(largeur)
    lignes << "17200 Royan".center(largeur)
    lignes << "Tel: 0546778080".center(largeur)
    lignes << "-" * largeur
    lignes << "*** AVOIR ***".center(largeur)
    lignes << "-" * largeur

    lignes << "N° : #{avoir.id.to_s.rjust(6, "0")}"

    date_emission = avoir.created_at.to_date
    date_limite = (date_emission >> 12) # décale de 12 mois

    lignes << "Date émission    : #{I18n.l(date_emission)}"
    lignes << "Valable jusqu'au : #{I18n.l(date_limite)}"

    lignes << "Montant : #{sprintf('%.2f €', avoir.montant)}"
    lignes << "Client : #{avoir.client&.prenom} #{avoir.client&.nom}".strip.presence || "Sans client"
    lignes << "-" * largeur
    lignes << "A présenter en caisse.".center(largeur)
    lignes << "-" * largeur

    lignes << ""
    lignes << "Merci de votre visite !".center(largeur)
    lignes << "\n" * 10 # pour pousser le ticket

    lignes.join("\n")
  end


end
