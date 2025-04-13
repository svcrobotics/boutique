class Client < ApplicationRecord
  validates :nom, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, uniqueness: true
  validates :telephone, uniqueness: true, allow_blank: true
  has_many :produits
  has_many :paiements
  has_many :ventes, dependent: :nullify
  has_many :versements

  validates :deposant, inclusion: { in: [ true, false ] }

  before_save :capitalize_nom_prenom


  private

  def capitalize_nom_prenom
    self.nom = nom.capitalize if nom.present?
    self.prenom = prenom.capitalize if prenom.present?
  end
end
