class ProduitsController < ApplicationController
  before_action :set_produit, only: %i[show edit update destroy]

  def index
    if params[:categorie].present?
      @produits = Produit.where(categorie: params[:categorie])
    else
      @produits = Produit.all
    end
  end


  def show
  end

  def new
    @produit = Produit.new
  end


  def create
    @produit = Produit.new(produit_params)
    if @produit.save
      respond_to do |format|
        format.html { redirect_to @produit, notice: "Produit créé avec succès." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @produit.update(produit_params)
      respond_to do |format|
        format.html { redirect_to @produit, notice: "Produit mis à jour avec succès." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @produit.destroy
    redirect_to produits_url, notice: "Produit supprimé."
  end

  private

  def set_produit
    @produit = Produit.find(params[:id])
  end

  def produit_params
    params.require(:produit).permit(:etat, :vendu, :prix_deposant, :date_depot, :client_id, :observation, :nom, :description, :prix, :prix_achat, :stock, :categorie, :date_achat, :facture, :image, :fournisseur_id)
  end
end
