FactoryBot.define do
  factory :reassort do
    produit { nil }
    quantite { 1 }
    date { "2025-05-10" }
    prix_achat { "9.99" }
    remise { false }
    taux_remise { 1 }
  end
end
