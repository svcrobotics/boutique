class Client < ApplicationRecord
  validates :nom, presence: true
  # validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  # validates :telephone, presence: true, uniqueness: true

  has_many :ventes, dependent: :nullify
  validates :deposant, inclusion: { in: [ true, false ] }
end
