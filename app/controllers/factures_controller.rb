class FacturesController < ApplicationController
  before_action :set_facture, only: %i[show edit update destroy]

  def index
    @factures = Facture.all
    @factures = @factures.where(fournisseur_id: params[:fournisseur_id]) if params[:fournisseur_id].present?
    @factures = @factures.where("numero LIKE ?", "%#{params[:numero]}%") if params[:numero].present?
    @factures = @factures.where(date: params[:date]) if params[:date].present?
    @factures = @factures.where("montant = ?", params[:montant]) if params[:montant].present?
  end

  def show; end

  def new
    @facture = Facture.new
  end

  def create
    @facture = Facture.new(facture_params)

    if @facture.save
      redirect_to factures_path, notice: "Facture ajoutée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @facture.update(facture_params)
      redirect_to factures_path, notice: "Facture mise à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facture.destroy
    redirect_to factures_path, notice: "Facture supprimée."
  end

  private

  def set_facture
    @facture = Facture.find(params[:id])
  end

  def facture_params
    params.require(:facture).permit(:numero, :date, :montant, :fournisseur_id, fichier: [])
  end
end
