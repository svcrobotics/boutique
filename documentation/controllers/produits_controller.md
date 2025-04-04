# ProduitsController

Ce contrôleur gère les opérations complètes liées aux produits : création, affichage, édition, suppression, recherche et impression d’étiquettes code-barres.

---

## `index`

- **Objectif** :  
  Affiche la liste des produits avec possibilité de recherche, de filtrage (état, catégorie, stock) et de pagination.  
  Peut aussi retourner un produit au format JSON via son code-barre.

- **Entrées** :
  - `params[:code_barre]` (String, optionnel) : retourne un produit en JSON si trouvé.
  - `params[:query]` (String, optionnel) : recherche par nom, code fournisseur, nom du fournisseur ou nom du client.
  - `params[:categorie]`, `params[:etat]`, `params[:stock]` : filtres supplémentaires.
  - Format : HTML ou JSON.

- **Sorties** :
  - `@produits` : liste filtrée et paginée.
  - Vue : `produits/index.html.erb` ou JSON

---

## `new`

- **Objectif** :  
  Affiche le formulaire de création d’un produit.

- **Sorties** :
  - `@produit` : instance vide.
  - Vue : `produits/new.html.erb`

---

## `create`

- **Objectif** :  
  Crée un nouveau produit avec ou sans dépôt-vente.

- **Entrées** :
  - `params[:produit]` (Hash) avec tous les champs du modèle Produit.

- **Traitement** :
  - Définit `en_depot = false` si le produit n'est pas en dépôt.
  - Sauvegarde en base.

- **Sorties** :
  - Redirection vers la fiche produit avec message de succès.
  - Sinon, réaffichage du formulaire.

---

## `edit` / `show`

- **Objectif** :  
  Affiche le formulaire d’édition (`edit`) ou les détails d’un produit (`show`).

- **Entrées** :
  - `params[:id]` (Integer)

- **Sorties** :
  - `@produit` : instance trouvée par ID.
  - Vues : `produits/edit.html.erb` ou `produits/show.html.erb`

---

## `update`

- **Objectif** :  
  Met à jour un produit existant, y compris les images et l’état dépôt.

- **Entrées** :
  - `params[:id]` (Integer)
  - `params[:produit]` (Hash)

- **Traitement** :
  - Si `etat` ≠ "depot_vente", désactive `en_depot`.
  - Ajoute les nouvelles images, sans supprimer les anciennes.
  - Met à jour le produit.

- **Sorties** :
  - Redirection vers le produit ou affichage du formulaire avec erreurs.

---

## `destroy`

- **Objectif** :  
  Supprime un produit.

- **Entrées** :
  - `params[:id]` (Integer)

- **Sorties** :
  - Redirection avec message de confirmation.

---

## `generate_label`

- **Objectif** :  
  Génère et imprime une étiquette pour un seul produit.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Génère un PDF format étiquette avec Prawn.
  - Génère le code-barres avec Barby.
  - Envoie le PDF à l’imprimante Dymo.
  - Met à jour `impression_code_barre` à `false`.

- **Sorties** :
  - Redirection vers `produits_path` avec message de succès.

---

## `generate_multiple_labels`

- **Objectif** :  
  Génère un PDF contenant plusieurs étiquettes (selon le stock) et les imprime en une fois.

- **Traitement** :
  - Recherche tous les produits avec `impression_code_barre = true`.
  - Pour chaque produit, imprime autant d’étiquettes que le stock.
  - Génère un fichier PDF unique.
  - Imprime le PDF puis réinitialise `impression_code_barre`.

- **Sorties** :
  - Redirection avec message de succès.

---

## 🔐 Méthodes privées

### `set_produit`
- Recherche et assigne un produit à `@produit` à partir de `params[:id]`.

### `produit_params`
- Filtre les champs autorisés pour la création ou la mise à jour d’un produit.

### `add_label_to_pdf(pdf, produit)`
- Dessine une étiquette sur le PDF pour un produit donné.

### `save_and_print_pdf(pdf, filename)`
- Enregistre un PDF temporaire et l’imprime via la commande `lp` sur l’imprimante Dymo, puis supprime le fichier.

