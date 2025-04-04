class Produit < ApplicationRecord
  # before_save :capitalize_nom
  before_save :set_default_prix_vente, if: -> { prix_achat.present? && (prix.blank? || prix == prix_achat * 3) }
  before_validation :capitalize_categorie
  has_many_attached :images

  belongs_to :fournisseur, optional: true
  belongs_to :client, optional: true

  CATEGORIES = [ "Vêtement", "Accessoire", "Chaussure", "Déco" ].freeze

  validates :categorie, inclusion: { in: CATEGORIES }

  # validates :code_barre, uniqueness: true, allow_blank: true
  # validates :impression_code_barre, inclusion: { in: [ true, false ] }

  before_create :generer_code_barre

  has_many :ventes_produits
  has_many :ventes, through: :ventes_produits
  has_many :versements

  validates :nom, presence: true
  validates :prix_achat, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :prix, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :prix_deposant, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :code_fournisseur, uniqueness: true, allow_blank: true

  # Liste des états valides sous forme de strings
  ETATS_VALIDES = [ "neuf", "occasion", "depot_vente" ].freeze

  validates :etat, presence: true, inclusion: { in: ETATS_VALIDES }

  before_save :vider_prix_achat_si_en_depot

  def vendu?
    ventes.exists?
  end

  # Renvoie les ventes du produit qui n'ont pas encore été versées
  def ventes_non_versees
    ventes.reject(&:versement_effectue?)
  end

  # Ce produit a-t-il été vendu sans que la déposante ait été payée ?
  def versement_en_attente?
    en_depot? && ventes_non_versees.any?
  end


  private

  def generer_code_barre
    return if self.code_barre.present? # Ne pas écraser un code-barre existant

    loop do
      random_code = rand(1..10000).to_s
      unless Produit.exists?(code_barre: random_code)
        self.code_barre = random_code
        break
      end
    end
  end

  def capitalize_nom
    self.nom = nom.capitalize if nom.present?
  end

  def set_default_prix_vente
    prix_calculé = (prix_achat * 3).to_i # On garde un entier
    dernier_chiffre = prix_calculé % 10 # Récupère le dernier chiffre
    prix_ajusté = prix_calculé - dernier_chiffre + 9.99 # Remplace le dernier chiffre par 9.99

    self.prix = prix_ajusté
  end

  def capitalize_categorie
    self.categorie = categorie.capitalize if categorie.present?
  end

  def vider_prix_achat_si_en_depot
    self.prix_achat = nil if en_depot?
  end
end
