require 'rails_helper'

RSpec.describe Fournisseur, type: :model do
  # ✅ Tester les validations
  describe "validations" do
    it "est valide avec un nom, un email et un téléphone" do
      fournisseur = Fournisseur.new(nom: "Entreprise ABC", email: "contact@abc.com", telephone: "0601020304", adresse: "12 rue de Paris", type_fournisseur: "Société (Neuf)")
      expect(fournisseur).to be_valid
    end

    it "est invalide sans nom" do
      fournisseur = Fournisseur.new(email: "contact@abc.com", telephone: "0601020304", adresse: "12 rue de Paris", type_fournisseur: "Société (Neuf)")
      expect(fournisseur).not_to be_valid
      expect(fournisseur.errors[:nom]).to include("Le nom est obligatoire")
    end

    it "est invalide si l'email est déjà pris" do
      Fournisseur.create!(nom: "ABC Corp", email: "contact@abc.com", telephone: "0601020304", adresse: "12 rue de Lyon", type_fournisseur: "Société (Neuf)")
      fournisseur = Fournisseur.new(nom: "XYZ Corp", email: "contact@abc.com", telephone: "0700000000", adresse: "15 avenue de Paris", type_fournisseur: "Particulier / Organisme (Occasion)")

      fournisseur.valid? # Force les validations
      expect(fournisseur).not_to be_valid
      expect(fournisseur.errors[:email]).to include("Cet email est déjà utilisé")
    end
  end

  # ✅ Tester CRUD (Create, Read, Update, Delete)
  describe "CRUD" do
    it "peut être créé" do
      fournisseur = Fournisseur.create!(nom: "Société Dupont", email: "dupont@societe.com", telephone: "0605050505", adresse: "34 rue du Commerce", type_fournisseur: "Société (Neuf)")
      expect(Fournisseur.find(fournisseur.id)).to eq(fournisseur)
    end

    it "peut être mis à jour" do
      fournisseur = Fournisseur.create!(nom: "Ancienne Société", email: "ancien@societe.com", telephone: "0610101010", adresse: "50 rue Lafayette", type_fournisseur: "Société (Neuf)")
      fournisseur.update(nom: "Nouvelle Société")
      expect(fournisseur.nom).to eq("Nouvelle Société")
    end

    it "peut être supprimé" do
      fournisseur = Fournisseur.create!(nom: "Fournisseur Test", email: "test@fournisseur.com", telephone: "0620202020", adresse: "90 boulevard Haussmann", type_fournisseur: "Société (Neuf)")
      expect { fournisseur.destroy }.to change { Fournisseur.count }.by(-1)
    end
  end
end
