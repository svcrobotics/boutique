FactoryBot.define do
  factory :avoir do
    vente { nil }
    montant { "9.99" }
    date { "2025-05-14" }
    utilise { false }
    remarques { "MyString" }
  end
end
