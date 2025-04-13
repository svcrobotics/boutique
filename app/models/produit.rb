class Produit < ApplicationRecord
  ### === CONSTANTES MÉTIER ===
  CATEGORIES = [ "Vêtement", "Accessoire", "Chaussure", "Déco" ].freeze
  ETATS_VALIDES = [ "neuf", "occasion", "depot_vente" ].freeze

  ### === ASSOCIATIONS ===
  belongs_to :fournisseur, optional: true
  belongs_to :client, optional: true

  has_many :ventes_produits
  has_many :ventes, through: :ventes_produits
  has_many :versements
  has_many :produits_versements
  has_many :versements, through: :produits_versements


  has_many_attached :photos
  has_many_attached :images # ← tu peux supprimer celui que tu n’utilises pas

  ### === VALIDATIONS ===
  validates :nom, presence: true, length: { maximum: 35 }
  validates :categorie, inclusion: { in: CATEGORIES }
  validates :code_barre, uniqueness: true
  validates :code_fournisseur, uniqueness: true, allow_blank: true
  validates :etat, presence: true, inclusion: { in: ETATS_VALIDES }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :prix_achat, :prix, :prix_deposant,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :impression_code_barre, inclusion: { in: [ true, false ] }
  validate :valider_coherence_etat_et_depot

  ### === CALLBACKS ===
  before_validation :strip_code_barre, :majuscule_sur_la_premiere_lettre_du_nom, :capitalize_categorie
  # before_save :set_default_prix_vente, if: -> { prix_achat.present? && (prix.blank? || prix == prix_achat * 3) }
  # before_save :vider_prix_achat_si_en_depot
  before_create :generer_code_barre
  before_validation :gerer_etat_depot_automatiquement

  ### === MÉTHODES MÉTIER ===

  after_save :mettre_a_jour_vendu

  def mettre_a_jour_vendu
    update_column(:vendu, ventes.any?)
  end

  # app/models/produit.rb
  def deja_verse?
    ProduitsVersement.exists?(produit_id: id)
  end

  ### === MÉTHODES PRIVÉES ===

  private

  # Nettoie le code-barres des caractères invisibles ou invalides
  def strip_code_barre
    self.code_barre = code_barre.to_s.strip.gsub(/[^0-9A-Za-z\-]/, "") if code_barre.present?
  end

  # Met une majuscule à la première lettre du nom (et garde le reste tel quel)
  def majuscule_sur_la_premiere_lettre_du_nom
    return if nom.blank?

    self.nom = nom.strip
    self.nom = nom[0].upcase + nom[1..] if self.nom.length > 0
  end

  # Met une majuscule à la catégorie (ex : "chaussure" → "Chaussure")
  def capitalize_categorie
    self.categorie = categorie.capitalize if categorie.present?
  end



  # Génère un code-barre unique si aucun n’a été fourni
  def generer_code_barre
    return if self.code_barre.present?

    loop do
      random_code = rand(1..10_000).to_s
      unless Produit.exists?(code_barre: random_code)
        self.code_barre = random_code
        break
      end
    end
  end



  def valider_coherence_etat_et_depot
    if en_depot? && etat != "depot_vente"
      errors.add(:etat, "doit être 'depot_vente' si le produit est en dépôt")
    elsif !en_depot? && etat == "depot_vente"
      errors.add(:en_depot, "doit être à true uniquement pour les produits en dépôt-vente")
    end
  end

  def gerer_etat_depot_automatiquement
    self.en_depot = (etat == "depot_vente")
  end
end
