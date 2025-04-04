require "application_system_test_case"

class FournisseursTest < ApplicationSystemTestCase
  setup do
    @fournisseur = fournisseurs(:one)
  end

  test "visiting the index" do
    visit fournisseurs_url
    assert_selector "h1", text: "Liste des Fournisseurs"
    assert_text @fournisseur.nom
  end

  test "creating a Fournisseur with Turbo" do
    visit fournisseurs_url
    click_on "Nouveau Fournisseur"

    within "#new_fournisseur" do
      fill_in "Nom", with: "Turbo Fournisseur"
      fill_in "Email", with: "turbo@example.com"
      fill_in "Téléphone", with: "0123456789"
      fill_in "Adresse", with: "Rue Turbo 123"
      select "Société (Neuf)", from: "Type de fournisseur"
      click_on "Ajouter"
    end

    assert_text "Turbo Fournisseur"
    assert_text "Fournisseur créé"
  end

  test "updating a Fournisseur with Turbo Frame" do
    visit fournisseurs_url

    within "tr##{dom_id(@fournisseur)}" do
      click_on "Modifier"
    end

    within "##{dom_id(@fournisseur, :edit)}" do
      fill_in "Nom", with: "Updated Fournisseur"
      click_on "Enregistrer"
    end

    assert_text "Updated Fournisseur"
    assert_text "Fournisseur mis à jour"
  end

  test "showing fournisseur details with Turbo Frame" do
    visit fournisseurs_url

    within "tr##{dom_id(@fournisseur)}" do
      click_on "Voir"
    end

    within "#fournisseur_details" do
      assert_text @fournisseur.nom
      assert_text @fournisseur.email
      assert_text @fournisseur.telephone
    end
  end

  test "destroying a Fournisseur with Turbo Stream" do
    visit fournisseurs_url

    within "tr##{dom_id(@fournisseur)}" do
      accept_confirm do
        click_on "Supprimer"
      end
    end

    assert_no_text @fournisseur.nom
    assert_text "Fournisseur supprimé"
  end

  test "errors when creating invalid Fournisseur" do
    visit fournisseurs_url
    click_on "Nouveau Fournisseur"

    within "#new_fournisseur" do
      fill_in "Nom", with: ""
      click_on "Ajouter"
      assert_text "Impossible d'enregistrer le fournisseur"
      assert_text "Nom doit être rempli"
    end
  end
end
