class VentesController < ApplicationController
  before_action :set_vente, only: %i[ show edit update destroy ]

  # GET /ventes or /ventes.json
  def index
    @ventes = Vente.all
  end

  # GET /ventes/1 or /ventes/1.json
  def show
  end

  # GET /ventes/new
  def new
    @vente = Vente.new
  end

  # GET /ventes/1/edit
  def edit
  end

  # POST /ventes or /ventes.json
  def create
    @vente = Vente.new(vente_params)

    respond_to do |format|
      if @vente.save
        format.html { redirect_to @vente, notice: "Vente was successfully created." }
        format.json { render :show, status: :created, location: @vente }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vente.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ventes/1 or /ventes/1.json
  def update
    respond_to do |format|
      if @vente.update(vente_params)
        format.html { redirect_to @vente, notice: "Vente was successfully updated." }
        format.json { render :show, status: :ok, location: @vente }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vente.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ventes/1 or /ventes/1.json
  def destroy
    @vente.destroy!

    respond_to do |format|
      format.html { redirect_to ventes_path, status: :see_other, notice: "Vente was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vente
      @vente = Vente.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def vente_params
      params.require(:vente).permit(:client_id, :total, :mode_paiement, :date_vente, produit_ids: [])
    end
end
