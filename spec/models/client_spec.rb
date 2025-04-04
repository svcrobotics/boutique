require 'rails_helper'

RSpec.describe Client, type: :model do
  # ✅ Tester les validations
  describe "validations" do
    it "est valide avec un nom, un email et un téléphone" do
      client = Client.new(nom: "Dupont", prenom: "Jean", email: "jean.dupont@email.com", telephone: "0601020304")
      expect(client).to be_valid
    end

    it "est invalide sans nom" do
      client = Client.new(prenom: "Jean", email: "jean.dupont@email.com", telephone: "0601020304")
      expect(client).not_to be_valid
      expect(client.errors[:nom]).to include("Le nom est obligatoire")
    end

    it "est invalide si l'email est déjà pris" do
      Client.create!(nom: "Dupont", email: "jean.dupont@email.com", telephone: "0601020304")
      client = Client.new(nom: "Martin", email: "jean.dupont@email.com", telephone: "0700000000")
      expect(client).not_to be_valid
      expect(client.errors[:email]).to include("Cet email est déjà utilisé")
    end

    it "est invalide si le téléphone est déjà pris" do
      Client.create!(nom: "Dupont", email: "jean.dupont@email.com", telephone: "0601020304")
      client = Client.new(nom: "Martin", email: "paul.martin@email.com", telephone: "0601020304")
      expect(client).not_to be_valid
      expect(client.errors[:telephone]).to include("Ce numéro de téléphone est déjà utilisé")
    end
  end

  # ✅ Tester CRUD
  describe "CRUD" do
    it "peut être créé" do
      client = Client.create!(nom: "Durand", prenom: "Marie", email: "marie.durand@email.com", telephone: "0700000001")
      expect(Client.find(client.id)).to eq(client)
    end

    it "peut être mis à jour" do
      client = Client.create!(nom: "Durand", prenom: "Marie", email: "marie.durand@email.com", telephone: "0700000001")
      client.update(email: "nouveau.email@email.com")
      expect(client.email).to eq("nouveau.email@email.com")
    end

    it "peut être supprimé" do
      client = Client.create!(nom: "Durand", prenom: "Marie", email: "marie.durand@email.com", telephone: "0700000001")
      expect { client.destroy }.to change { Client.count }.by(-1)
    end
  end

  # ✅ Tester le moteur de recherche
  describe "Recherche de client" do
    before do
      Client.create!(nom: "Curie", prenom: "Marie", email: "marie.curie@email.com", telephone: "0700000002")
      Client.create!(nom: "Martin", prenom: "Paul", email: "paul.martin@email.com", telephone: "0700000003")
    end

    it "trouve un client par nom" do
      result = Client.where("nom LIKE ?", "%Curie%")
      expect(result.count).to eq(1)
      expect(result.first.nom).to eq("Curie")
    end

    it "trouve un client par prénom" do
      result = Client.where("prenom LIKE ?", "%Paul%")
      expect(result.count).to eq(1)
      expect(result.first.prenom).to eq("Paul")
    end

    it "trouve un client par téléphone" do
      result = Client.where("telephone LIKE ?", "%0700000003%")
      expect(result.count).to eq(1)
      expect(result.first.telephone).to eq("0700000003")
    end

    it "renvoie aucun résultat si le client n'existe pas" do
      result = Client.where("nom LIKE ?", "%Inexistant%")
      expect(result.count).to eq(0)
    end
  end
end
