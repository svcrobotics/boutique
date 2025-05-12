class ReassortsController < ApplicationController
  before_action :set_produit

  def new
    @reassort = @produit.reassorts.new
  end

  def create
    @reassort = @produit.reassorts.new(reassort_params)
    if @reassort.save
      @produit.increment!(:stock, @reassort.quantite)
      redirect_to produit_path(@produit), notice: "Réassort ajouté avec succès."
    else
      render :new
    end
  end

  def imprimer_etiquettes
    reassort = Reassort.find(params[:id])
    produit = reassort.produit
    quantite = reassort.quantite

    pdf = Prawn::Document.new(page_size: [162, 91], margin: 0)
    first_page = true

    quantite.times do
      pdf.start_new_page unless first_page
      first_page = false
      ProduitsController.new.send(:add_label_to_pdf, pdf, produit)
    end

    ProduitsController.new.send(:save_and_print_pdf, pdf, "etiquettes_reassort_#{reassort.id}")

    redirect_to produit_path(produit), notice: "#{quantite} étiquette(s) imprimée(s) pour le réassort."
  end

  private

  def set_produit
    @produit = Produit.find(params[:produit_id])
  end

  def reassort_params
    params.require(:reassort).permit(:quantite, :date, :prix_achat, :remise, :taux_remise)
  end
end
