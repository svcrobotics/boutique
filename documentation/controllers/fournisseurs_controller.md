# FournisseursController

Ce contrôleur gère la création, l’affichage, la modification et la suppression des fournisseurs (sociétés ou particuliers) qui approvisionnent la boutique.

---

## `index`

- **Objectif** :  
  Affiche la liste complète des fournisseurs.

- **Entrées** :
  - Aucun paramètre utilisé actuellement (le filtre par nom est commenté).

- **Traitement** :
  - Charge tous les fournisseurs avec `Fournisseur.all`.

- **Sorties** :
  - `@fournisseurs` : liste de tous les fournisseurs.
  - Vue : `fournisseurs/index.html.erb`

---

## `show`

- **Objectif** :  
  Affiche les détails d’un fournisseur spécifique.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Recherche du fournisseur avec `Fournisseur.find`.

- **Sorties** :
  - `@fournisseur` : instance du fournisseur ciblé.
  - Vue : `fournisseurs/show.html.erb`

---

## `new`

- **Objectif** :  
  Affiche le formulaire de création d’un nouveau fournisseur.

- **Entrées** : aucune

- **Sorties** :
  - `@fournisseur` : instance vide `Fournisseur.new`
  - Vue : `fournisseurs/new.html.erb`

---

## `create`

- **Objectif** :  
  Crée un nouveau fournisseur à partir des données saisies dans le formulaire.

- **Entrées** :
  - `params[:fournisseur]` (Hash) avec les champs :
    - `nom` (String)
    - `email` (String)
    - `telephone` (String)
    - `adresse` (Text)
    - `type_fournisseur` (String)

- **Traitement** :
  - Création d’une instance avec `Fournisseur.new`.
  - Sauvegarde des données en base.

- **Sorties** :
  - Redirection vers `fournisseurs_path` avec message de succès.
  - Ou réaffichage du formulaire en cas d’erreur.

---

## `edit`

- **Objectif** :  
  Affiche le formulaire d’édition d’un fournisseur.

- **Entrées** :
  - `params[:id]` (Integer)

- **Sorties** :
  - `@fournisseur` : instance existante à modifier.
  - Vue : `fournisseurs/edit.html.erb`

---

## `update`

- **Objectif** :  
  Met à jour les données d’un fournisseur existant.

- **Entrées** :
  - `params[:id]` (Integer)
  - `params[:fournisseur]` (Hash)

- **Traitement** :
  - Recherche du fournisseur ciblé.
  - Mise à jour avec les nouveaux champs.

- **Sorties** :
  - Redirection vers `fournisseurs_path` avec message de succès.
  - Ou réaffichage du formulaire avec erreurs.

---

## `destroy`

- **Objectif** :  
  Supprime un fournisseur de la base de données.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Recherche et suppression de l’instance.

- **Sorties** :
  - Redirection vers `fournisseurs_path` avec message de confirmation.

---

## 🔐 Méthodes privées

### `set_fournisseur`

- **Objectif** :  
  Charger un fournisseur à partir de son identifiant pour les actions `show`, `edit`, `update`, `destroy`.

- **Entrées** :
  - `params[:id]` (Integer)

- **Sorties** :
  - `@fournisseur` (Fournisseur)

---

### `fournisseur_params`

- **Objectif** :  
  Filtrer les paramètres autorisés pour la création ou la mise à jour.

- **Entrées** :
  - `params[:fournisseur]` (Hash)

- **Sorties** :
  - Hash filtré contenant : `nom`, `email`, `telephone`, `adresse`, `type_fournisseur`
