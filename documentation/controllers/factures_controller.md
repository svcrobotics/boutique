# FacturesController

Ce contrôleur gère la gestion des factures fournisseurs dans l'application : création, modification, suppression, affichage et filtrage.

---

## `index`

- **Objectif** :  
  Affiche la liste des factures avec possibilité de filtrage sur plusieurs champs.

- **Entrées** (tous les paramètres sont optionnels) :
  - `params[:fournisseur_id]` (Integer) : filtre par fournisseur.
  - `params[:numero]` (String) : filtre par numéro de facture (recherche partielle).
  - `params[:date]` (Date) : filtre par date exacte.
  - `params[:montant]` (Decimal) : filtre par montant exact.

- **Traitement** :
  - Charge toutes les factures.
  - Applique un filtrage conditionnel sur les champs précisés.

- **Sorties** :
  - `@factures` : liste filtrée des factures.
  - Vue HTML : `factures/index.html.erb`

---

## `show`

- **Objectif** :  
  Affiche les détails d’une facture.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Recherche de la facture avec `Facture.find`.

- **Sorties** :
  - `@facture` : instance de la facture.
  - Vue : `factures/show.html.erb`

---

## `new`

- **Objectif** :  
  Affiche le formulaire de création d’une nouvelle facture.

- **Entrées** : aucune

- **Sorties** :
  - `@facture` : instance vide `Facture.new`
  - Vue : `factures/new.html.erb`

---

## `create`

- **Objectif** :  
  Enregistre une nouvelle facture dans la base.

- **Entrées** :
  - `params[:facture]` (Hash) : doit contenir les clés suivantes :
    - `numero` (String)
    - `date` (Date)
    - `montant` (Decimal)
    - `fournisseur_id` (Integer)
    - `fichier[]` (Array of fichiers attachés, optionnel)

- **Traitement** :
  - Création d’une nouvelle instance avec les paramètres autorisés.
  - Sauvegarde en base de données.

- **Sorties** :
  - Redirection vers `factures_path` avec message de succès.
  - Ou réaffichage du formulaire avec erreurs.

---

## `edit`

- **Objectif** :  
  Affiche le formulaire d’édition pour une facture existante.

- **Entrées** :
  - `params[:id]` (Integer)

- **Sorties** :
  - `@facture` : instance de la facture ciblée.
  - Vue : `factures/edit.html.erb`

---

## `update`

- **Objectif** :  
  Met à jour une facture existante.

- **Entrées** :
  - `params[:id]` (Integer)
  - `params[:facture]` (Hash)

- **Traitement** :
  - Recherche de la facture.
  - Mise à jour des champs autorisés.

- **Sorties** :
  - Redirection vers `factures_path` avec message de succès.
  - Ou réaffichage du formulaire avec erreurs.

---

## `destroy`

- **Objectif** :  
  Supprime une facture.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Recherche et suppression de la facture.

- **Sorties** :
  - Redirection vers `factures_path` avec message de confirmation.

---

## 🔐 Méthodes privées

### `set_facture`

- **Objectif** :  
  Charger l’instance de la facture ciblée pour `show`, `edit`, `update`, `destroy`.

- **Entrées** :
  - `params[:id]` (Integer)

- **Sorties** :
  - `@facture` (Facture)

---

### `facture_params`

- **Objectif** :  
  Filtrer les paramètres autorisés à la création ou modification d’une facture.

- **Entrées** :
  - `params[:facture]` (Hash)

- **Sorties** :
  - Hash contenant : `numero`, `date`, `montant`, `fournisseur_id`, `fichier[]`
