class FournisseursController < ApplicationController
  before_action :set_fournisseur, only: %i[show edit update destroy]

  # GET /fournisseurs or /fournisseurs.json
  def index
    @fournisseurs = Fournisseur.all
  end

  # GET /fournisseurs/1 or /fournisseurs/1.json
  def show
  end

  # GET /fournisseurs/new
  def new
    @fournisseur = Fournisseur.new
    render partial: "form", locals: { fournisseur: @fournisseur }
  end

  # GET /fournisseurs/1/edit
  def edit
  end

  # POST /fournisseurs or /fournisseurs.json
  def create
    @fournisseur = Fournisseur.new(fournisseur_params)

    if @fournisseur.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("fournisseur_select", partial: "fournisseurs/fournisseur", locals: { fournisseur: @fournisseur }),
            turbo_stream.remove("new_fournisseur")
          ]
        end
        format.html { redirect_to fournisseurs_path, notice: "Fournisseur créé avec succès." }
      end
    else
      render partial: "form", locals: { fournisseur: @fournisseur }, status: :unprocessable_entity
    end
  end


  # PATCH/PUT /fournisseurs/1 or /fournisseurs/1.json
  def update
    respond_to do |format|
      if @fournisseur.update(fournisseur_params)
        format.html { redirect_to @fournisseur, notice: "Fournisseur was successfully updated." }
        format.json { render :show, status: :ok, location: @fournisseur }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fournisseur.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fournisseurs/1 or /fournisseurs/1.json
  def destroy
    @fournisseur.destroy!

    respond_to do |format|
      format.html { redirect_to fournisseurs_path, status: :see_other, notice: "Fournisseur was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fournisseur
      @fournisseur = Fournisseur.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fournisseur_params
      params.expect(fournisseur: [ :nom, :type_fournisseur, :email, :telephone, :adresse ])
    end
end
