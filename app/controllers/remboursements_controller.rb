# app/controllers/caisse/remboursements_controller.rb
module Caisse
  class RemboursementsController < ApplicationController
    def index
      @avoirs_remboursements = Avoir
        .includes(:vente, :client)
        .where("motif LIKE ?", "Remboursement produit%")
        .order(date: :desc)
    end
  end
end
