class FournisseursController < ApplicationController
  before_action :set_fournisseur, only: %i[show edit update destroy]

  def index
    @fournisseurs = Fournisseur.all

    # Filtre par nom
    # @fournisseurs = Fournisseur.where("nom LIKE ?", "%#{params[:query]}%") if params[:query].present?

    # Vérifie s'il y a des résultats avant d'utiliser Pagy
    # if @fournisseurs.any?
    #  @pagy, @fournisseurs = pagy(@fournisseurs)
    # end
  end

  def show
  end

  def new
    @fournisseur = Fournisseur.new
  end

  def create
    @fournisseur = Fournisseur.new(fournisseur_params)

    if @fournisseur.save
      redirect_to fournisseurs_path, notice: "Fournisseur ajouté avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @fournisseur = Fournisseur.find(params[:id])
  end

  def update
    @fournisseur = Fournisseur.find(params[:id])
    if @fournisseur.update(fournisseur_params)
      redirect_to fournisseurs_path, notice: "Fournisseur modifié avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fournisseur = Fournisseur.find(params[:id])
    @fournisseur.destroy

    redirect_to fournisseurs_path, notice: "Fournisseur supprimé."
  end



  private

  def set_fournisseur
    @fournisseur = Fournisseur.find(params[:id])
  end

  def fournisseur_params
    params.require(:fournisseur).permit(:nom, :email, :telephone, :adresse, :type_fournisseur)
  end
end
