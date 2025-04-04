FactoryBot.define do
  factory :versement do
    client { nil }
    produit { nil }
    vente { nil }
    montant { "9.99" }
    date { "2025-03-31" }
  end
end
