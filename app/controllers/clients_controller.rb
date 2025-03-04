class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = Client.all
  end

  def show
    @client = Client.find(params[:id])
    render layout: false if turbo_frame_request?
  end


  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to clients_path, notice: "Client ajouté avec succès." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @client = Client.find(params[:id])
    render layout: false if turbo_frame_request?
  end

  def cancel_edit
    @client = Client.find(params[:id])
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("client_edit_#{@client.id}", "") }
      format.html { redirect_to clients_path }
    end
  end



  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("client_#{@client.id}", partial: "clients/client", locals: { client: @client }),
            turbo_stream.replace("client_edit_#{@client.id}", "")
          ]
        end
        format.html { redirect_to clients_path, notice: "Client modifié avec succès." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.turbo_stream  # Rendra la vue destroy.turbo_stream.erb
      format.html { redirect_to clients_path, notice: "Client supprimé avec succès." }
    end
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:nom, :email, :telephone, :deposant, :ancien_id)
  end
end
