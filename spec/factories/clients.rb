FactoryBot.define do
  factory :client do
    nom { "Dupont" }
    prenom { "Jean" }
    email { "jean.dupont@example.com" }
    telephone { "0612345678" }
    ancien_id { nil } # ou une valeur si nécessaire
    deposant { false } # ou true si tu veux tester un déposant
  end
end
