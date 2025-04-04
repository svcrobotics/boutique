class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pagy::Backend
  helper_method :paiements_en_attente

  private

  def paiements_en_attente
    Client.where(deposant: true).includes(:produits).map do |client|
      produits = client.produits.select(&:versement_en_attente?)
      next if produits.empty?

      {
        client: client,
        produits: produits,
        total: produits.sum(&:prix_deposant)
      }
    end.compact
  end
end
