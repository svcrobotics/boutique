FactoryBot.define do
  factory :facture do
    numero { "MyString" }
    date { "2025-03-15" }
    montant { "9.99" }
    fournisseur { nil }
    fichier { "MyString" }
  end
end
