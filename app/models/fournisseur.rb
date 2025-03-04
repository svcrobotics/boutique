class Fournisseur < ApplicationRecord
  has_many :produits, dependent: :nullify # Si un fournisseur est supprimé, ses produits restent mais le fournisseur_id devient NULL

  validates :nom, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :telephone, length: { minimum: 10, maximum: 15 }, allow_blank: true
  validates :type_fournisseur, inclusion: { in: [ "Société (Neuf)", "Particulier / Organisme (Occasion)" ] }
end
