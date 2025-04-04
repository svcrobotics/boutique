FactoryBot.define do
  factory :paiement do
    montant { "9.99" }
    date_paiement { "2025-03-26" }
    methode_paiement { "MyString" }
    effectue { false }
    numero_recu { 1 }
    client { nil }
  end
end
