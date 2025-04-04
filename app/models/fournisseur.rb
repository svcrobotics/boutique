class Fournisseur < ApplicationRecord
  has_many :produits, dependent: :nullify # Si un fournisseur est supprimé, ses produits restent mais le fournisseur_id devient NULL
  validates :nom, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, uniqueness: { case_sensitive: false }
  validates :telephone, length: { minimum: 10, maximum: 15 }, allow_blank: true

  TYPES_FOURNISSEUR = [ "Société (Neuf)", "Particulier / Organisme (Occasion)" ].freeze
  validates :type_fournisseur, inclusion: { in: TYPES_FOURNISSEUR }

  before_save :capitalize_nom


  private

  def capitalize_nom
    self.nom = nom.capitalize if nom.present?
  end
end
