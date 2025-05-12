# app/controllers/especes_controller.rb
class EspecesController < ApplicationController
  def index
    jour = Time.zone.today
    
    @mouvements = MouvementEspece.order(date: :desc)
    @versements = Versement.where(methode_paiement: "Espèces")

    total_entrees = MouvementEspece.where(sens: "entrée").sum(:montant)
    total_sorties = MouvementEspece.where(sens: "sortie").sum(:montant)
    total_versements = @versements.sum(:montant)

    @fond_de_caisse = total_entrees - total_sorties - total_versements
  end


  def new
    @mouvement = MouvementEspece.new
  end

  def create
    type = params[:type_operation]
    montant = params[:montant].to_d
    date = params[:date]
    compte = params[:compte].presence

    case type
    when "apport"
      sens = "entrée"
      motif = "Apport banque"
    when "retrait_perso"
      sens = "sortie"
      motif = "Retrait perso"
    when "depot_compte"
      sens = "sortie"
      motif = "Dépôt compte pro"
    else
      redirect_to new_espece_path, alert: "Type d'opération invalide." and return
    end

    mouvement = MouvementEspece.new(
      sens: sens,
      motif: motif,
      montant: montant,
      date: date,
      compte: compte
    )

    if mouvement.save
      redirect_to especes_path, notice: "Mouvement enregistré avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end



  private

  def mouvement_params
    params.require(:mouvement_espece).permit(:sens, :motif, :montant, :date, :compte)
  end
end
