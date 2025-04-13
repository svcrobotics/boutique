FactoryBot.define do
  factory :client do
    nom { "Client" }
    prenom { "Test" }
    sequence(:email) { |n| "client#{n}@example.com" }
    sequence(:telephone) { |n| "0600000#{n.to_s.rjust(3, '3')}" }
  end
end
