require 'rails_helper'

RSpec.describe "Gestion des clients", type: :system do
  before do
    driven_by(:rack_test) # Change en :selenium_chrome si besoin de voir le navigateur
  end

  let!(:client) { create(:client, nom: "Dupont", prenom: "Jean", email: "jean@example.com", telephone: "0612345678") }

  ### 🟢 1. Tester la création d'un client
  it "crée un nouveau client" do
    visit new_client_path

    fill_in "Nom", with: "Martin"
    fill_in "Prénom", with: "Paul"
    fill_in "Email", with: "paul.martin@example.com"
    fill_in "Téléphone", with: "0654321098"

    click_button "Créer Client"

    expect(page).to have_content "Le client a été créé avec succès"
    expect(page).to have_content "Martin"
    expect(page).to have_content "Paul"
  end

  ### 🟡 2. Tester la lecture (affichage) d'un client
  it "affiche un client" do
    visit client_path(client)

    expect(page).to have_content "Dupont"
    expect(page).to have_content "Jean"
    expect(page).to have_content "jean@example.com"
    expect(page).to have_content "0612345678"
  end

  ### 🔵 3. Tester la mise à jour d'un client
  it "modifie un client" do
    visit edit_client_path(client)

    fill_in "Nom", with: "Durand"
    fill_in "Prénom", with: "Pierre"
    click_button "Mettre à jour Client"

    expect(page).to have_content "Le client a été mis à jour avec succès"
    expect(page).to have_content "Durand"
    expect(page).to have_content "Pierre"
  end

  ### 🔴 4. Tester la suppression d'un client
  it "supprime un client" do
    visit clients_path

    expect(page).to have_content "Dupont"
    click_link "Supprimer", match: :first

    expect(page).to have_content "Le client a été supprimé avec succès"
    expect(page).not_to have_content "Dupont"
  end
end
