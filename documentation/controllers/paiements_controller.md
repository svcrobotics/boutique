# PaiementsController

Ce contrôleur gère les paiements vers les déposants lorsque leurs produits en dépôt ont été vendus. Il permet d'afficher les paiements, de créer un nouveau paiement et d'imprimer un reçu.

---

## `index`

- **Objectif** :  
  Affiche la liste des paiements effectués, avec un affichage dédié aux paiements en attente.

- **Entrées** :
  - `params[:client_id]` (Integer, optionnel) : si présent, affiche uniquement les paiements d’un client.

- **Traitement** :
  - Si `client_id` présent : recherche du client et de ses paiements.
  - Sinon : chargement de tous les paiements avec leurs clients associés.
  - Chargement des paiements en attente (clients ayant des produits vendus mais non payés).

- **Sorties** :
  - `@paiements` : liste des paiements.
  - `@paiements_en_attente` : liste des paiements en attente (clients + produits + total).
  - Vue : `paiements/index.html.erb`

---

## `new`

- **Objectif** :  
  Affiche le formulaire pour créer un paiement automatique vers un déposant.

- **Entrées** :
  - `params[:client_id]` (Integer)

- **Traitement** :
  - Recherche du client.
  - Sélection des produits en dépôt vendus mais non encore payés.
  - Calcul du montant total à verser.

- **Sorties** :
  - `@paiement` : pré-rempli avec le client, la date du jour et le montant à verser.
  - Vue : `paiements/new.html.erb`

---

## `create`

- **Objectif** :  
  Enregistre un nouveau paiement vers le déposant.

- **Entrées** :
  - `params[:client_id]` (Integer)
  - `params[:paiement]` (Hash) avec les champs : `methode_paiement`, `montant`, `numero_recu`...

- **Traitement** :
  - Construction d’un paiement lié au client.
  - Affectation automatique du montant à verser (calculé depuis les produits non payés).
  - Marque le paiement comme effectué (`effectue = true`).
  - Sauvegarde en base.
  - Lien avec les ventes concernées.
  - Impression automatique du reçu (appel de `imprimer_paiement`).

- **Sorties** :
  - Redirection vers la fiche client avec confirmation.
  - Vue HTML ou `turbo_stream` en fonction du format.

---

## `show`

- **Objectif** :  
  Affiche les détails d’un paiement spécifique.

- **Entrées** :
  - `params[:id]` (Integer)

- **Sorties** :
  - `@paiement` : instance du paiement
  - Vue : `paiements/show.html.erb`

---

## `imprimer`

- **Objectif** :  
  Réimprime le reçu d’un paiement.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Recherche du paiement.
  - Appel à `imprimer_paiement(paiement)` pour générer et envoyer à l’imprimante.

- **Sorties** :
  - Redirection vers la fiche client avec message de confirmation.

---

## 🔐 Méthodes privées

### `set_client`

- Recherche et assigne le client ciblé à `@client` via `params[:client_id]`.

---

### `paiement_params`

- Filtre les paramètres autorisés pour la création d’un paiement :
  - `:methode_paiement`, `:montant`, `:date_paiement`, `:numero_recu`

---

### `montant_a_verser(client)`

- Calcule la somme totale à verser au client en additionnant les `prix_deposant` des produits non encore payés.

---

### `produits_non_payes(client)`

- Retourne les produits en dépôt d’un client qui ont été vendus mais non encore associés à un paiement.

---

### `paiements_en_attente`

- Retourne une liste de clients déposants ayant des produits impayés, avec le détail des produits et le total à verser.

---

### `generer_recu_texte(paiement)`

- Génère le contenu texte du reçu de paiement (avec en-tête, liste des produits, montant total).

---

### `produits_payes_par(paiement)`

- Retourne les produits payés dans un paiement donné en parcourant les ventes liées et leurs lignes de produits.

---

### `encode_with_iconv(text)`

- Convertit un fichier texte UTF-8 en CP858 (encodage pour imprimante thermique).

---

### `imprimer_paiement(paiement)`

- Génère le reçu, le convertit en CP858, puis l’envoie à l’imprimante système via `lp`.

