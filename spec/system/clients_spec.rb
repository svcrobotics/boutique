require 'rails_helper'

RSpec.describe "Gestion des clients", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:client) { create(:client, nom: "Dupont", prenom: "Jean", email: "jean@example.com", telephone: "0612345678") }

  ### 🟢 1. Création d'un client
  it "crée un nouveau client" do
    visit new_client_path

    fill_in "Nom", with: "Martin"
    fill_in "Prénom", with: "Paul"
    fill_in "Email", with: "paul@example.com"
    fill_in "Téléphone", with: "0600000000"

    click_button "Créer le client"

    expect(page).to have_content "Client ajoutée."
    expect(page).to have_content "Martin"
    expect(page).to have_content "Paul"
  end

  ### 🟡 2. Affichage d’un client
  it "affiche un client" do
    visit client_path(client)

    expect(page).to have_content "Dupont"
    expect(page).to have_content "Jean"
    expect(page).to have_content "jean@example.com"
    expect(page).to have_content "0612345678"
  end

  ### 🔵 3. Modification d’un client
  it "modifie un client" do
    visit edit_client_path(client)

    fill_in "Nom", with: "Durand"
    fill_in "Prénom", with: "Pierre"
    fill_in "Email", with: "pierre@example.com"
    fill_in "Téléphone", with: "0611223344"

    click_button "Créer le client" # ← même bouton que pour la création

    expect(page).to have_content "Client mis à jour avec succès."
    expect(page).to have_content "Durand"
    expect(page).to have_content "Pierre"
  end

  ### 🔴 4. Suppression d’un client
  it "supprime un client" do
    visit clients_path

    expect(page).to have_content "Dupont"
    click_button "Supprimer", match: :first

    expect(page).to have_content "Client supprimé avec succès."
    expect(page).not_to have_content "Dupont"
  end

  ### 🟣 5. Affichage de la liste
  it "affiche la liste des clients" do
    create(:client, nom: "Martin", prenom: "Paul")
    create(:client, nom: "Lemoine", prenom: "Claire")

    visit clients_path

    expect(page).to have_content "Dupont"
    expect(page).to have_content "Martin"
    expect(page).to have_content "Lemoine"
  end

  ### 🔍 6. Recherche d’un client par nom
  it "recherche un client par son nom" do
    visit clients_path
    fill_in "query", with: "Dupont"
    click_button "Rechercher"

    expect(page).to have_content "Dupont"
    expect(page).not_to have_content "Martin"
  end
end
