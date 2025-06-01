FactoryBot.define do
  factory :remboursement do
    vente { nil }
    montant { "9.99" }
    date { "2025-05-31" }
    mode { "MyString" }
    motif { "MyString" }
  end
end
