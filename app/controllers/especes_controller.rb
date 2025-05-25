# app/controllers/especes_controller.rb
class EspecesController < ApplicationController
  def index
    jour = Time.zone.today

    @mouvements = MouvementEspece.order(date: :desc)
    @versements = Versement.where(methode_paiement: "Espèces") # tous les versements affichés

    fond_initial = 0

    total_entrees = MouvementEspece.where(date: jour, sens: "entrée").sum(:montant)
    total_sorties = MouvementEspece.where(date: jour, sens: "sortie").sum(:montant)
    total_versements_jour = Versement.where(methode_paiement: "Espèces", created_at: jour.all_day).sum(:montant)
    total_ventes_especes = Vente.where(created_at: jour.all_day, annulee: [false, nil]).sum(:espece)

    @fond_de_caisse = fond_initial + total_entrees - total_sorties - total_versements_jour + total_ventes_especes
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
    when "apport_perso"
      sens = "entrée"
      motif = "Apport perso"
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
