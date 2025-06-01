class EspecesController < ApplicationController
  def index
    jour = Time.zone.today

    @mouvements = MouvementEspece
                  .select("mouvement_especes.*, CASE WHEN sens = 'entrée' THEN 0 ELSE 1 END AS ordre_sens")
                  .order("date DESC, ordre_sens ASC, created_at DESC")
    @versements = Versement.where(methode_paiement: "Espèces")

    fond_initial = 0

    total_entrees = MouvementEspece.where(date: jour, sens: "entrée").sum(:montant)
    total_sorties = MouvementEspece.where(date: jour, sens: "sortie").sum(:montant)
    total_versements_jour = Versement.where(methode_paiement: "Espèces", created_at: jour.all_day).sum(:montant)
    total_ventes_especes = Caisse::Vente.where(created_at: jour.all_day, annulee: [false, nil]).sum(:espece)

    @fond_de_caisse = fond_initial + total_entrees - total_sorties - total_versements_jour
  end

  def new
    @mouvement = MouvementEspece.new
  end

  def create
    # Si on a un param :vente_id, on veut enregistrer automatiquement
    # l’entrée (et le rendu) pour cette vente. Mais on doit vérifier que
    # l’entrée n’existe pas déjà, sinon on duplique.
    if params[:vente_id].present?
      vente = Caisse::Vente.find_by(id: params[:vente_id])

      if vente
        montant_espece = vente.espece.to_d
        total_net      = vente.total_net.to_d
        total_regle    = vente.cb.to_d + vente.cheque.to_d + vente.amex.to_d + montant_espece
        reste          = total_net - total_regle

        # —— ENREGISTREMENT DE L’ENTRÉE (si pas déjà existante) ——
        if montant_espece > 0
          motif_entree = "Encaissement espèces vente n°#{vente.id}"

          unless MouvementEspece.exists?(sens: "entrée", motif: motif_entree, vente_id: vente.id)
            MouvementEspece.create!(
              sens:    "entrée",
              motif:   motif_entree,
              montant: montant_espece,
              date:    vente.date_vente,
              vente:   vente
            )
          end
        end

        # —— ENREGISTREMENT DU RENDU (sortie) ——
        # On calcule le rendu : si e - (net - autres) > 0
        rendu = montant_espece - reste
        if rendu > 0
          motif_sortie = "Rendu monnaie vente n°#{vente.id}"

          # On stocke le montant en positif, car c'est déjà un sens "sortie"
          unless MouvementEspece.exists?(sens: "sortie", motif: motif_sortie, vente_id: vente.id)
            MouvementEspece.create!(
              sens:    "sortie",
              motif:   motif_sortie,
              montant: rendu.round(2),
              date:    vente.date_vente,
              vente:   vente
            )
          end
        end

        redirect_to especes_path, notice: "Mouvements en espèces enregistrés pour la vente n°#{vente.id}."
      else
        redirect_to especes_path, alert: "Vente introuvable."
      end

      return
    end

    # —— GESTION MANUELLE (= sans :vente_id) ——
    type    = params[:type_operation]
    montant = params[:montant].to_d
    date    = params[:date]
    compte  = params[:compte].presence

    case type
    when "apport"
      sens  = "entrée"
      motif = "Apport banque"
    when "apport_perso"
      sens  = "entrée"
      motif = "Apport perso"
    when "retrait_perso"
      sens  = "sortie"
      motif = "Retrait perso"
    when "depot_compte"
      sens  = "sortie"
      motif = "Dépôt compte pro"
    else
      redirect_to new_espece_path, alert: "Type d'opération invalide." and return
    end

    mouvement = MouvementEspece.new(
      sens:    sens,
      motif:   motif,
      montant: montant,
      date:    date,
      compte:  compte
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
