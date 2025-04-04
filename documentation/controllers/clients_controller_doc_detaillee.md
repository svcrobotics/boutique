# Documentation détaillée du `ClientsController`

Ce contrôleur gère toutes les actions relatives aux clients de la boutique. Il permet de créer, modifier, afficher, supprimer, rechercher et exporter les données clients.

---

## `index`

- **Objectif** :  
  Affiche la liste complète des clients, avec la possibilité de faire une recherche multicritère (nom, prénom, téléphone, ancien identifiant) et une pagination automatique si des résultats sont présents.

- **Entrées** :
  - `params[:query]` (String, optionnel) :  
    Une chaîne de caractères utilisée pour filtrer les clients en fonction de leur `nom`, `prenom`, `telephone` ou `ancien_id`.

- **Traitement** :
  - Trie tous les clients par `nom` puis `prenom`.
  - Applique un filtre si `params[:query]` est fourni.
  - Si des résultats sont présents, les résultats sont paginés avec la gem `pagy`.

- **Sorties** :
  - `@clients` : collection des clients filtrés, triés et paginés.
  - `@pagy` : objet de pagination.
  - Vue HTML : `clients/index.html.erb`

---

## `show`

- **Objectif** :  
  Affiche les détails d’un client spécifique.

- **Entrées** :
  - `params[:id]` (Integer) : ID du client à afficher.

- **Traitement** :
  - Recherche du client via son identifiant avec `Client.find`.

- **Sorties** :
  - `@client` : instance du client.
  - Vue HTML : `clients/show.html.erb`

---

## `new`

- **Objectif** :  
  Affiche le formulaire de création d’un nouveau client.

- **Entrées** :
  - `params[:retour]` (String, optionnel) : peut contenir une redirection ciblée après création.

- **Traitement** :
  - Initialise une nouvelle instance `Client.new`.

- **Sorties** :
  - `@client` : instance vide.
  - `@retour` : chaîne de redirection si précisée.
  - Vue HTML : `clients/new.html.erb`

---

## `create`

- **Objectif** :  
  Crée un nouveau client à partir des données saisies dans le formulaire.

- **Entrées** :
  - `params[:client]` (Hash) : contient les données du client (`nom`, `prenom`, etc.).
  - `params[:retour]` (String, optionnel) : utilisé pour rediriger vers une création de vente si précisé.

- **Traitement** :
  - Crée un client avec `Client.new`.
  - Si sauvegarde réussie :
    - Redirige vers la page des ventes si `retour == "ventes"`.
    - Sinon, redirige vers l’index des clients.
  - Si échec, réaffiche le formulaire avec les erreurs.

- **Sorties** :
  - Redirection ou rendu de `clients/new.html.erb` avec erreurs.

---

## `edit`

- **Objectif** :  
  Affiche le formulaire d’édition d’un client existant.

- **Entrées** :
  - `params[:id]` (Integer) : identifiant du client.

- **Traitement** :
  - Recherche du client concerné par son ID.

- **Sorties** :
  - `@client` : client à éditer.
  - Vue HTML : `clients/edit.html.erb`

---

## `update`

- **Objectif** :  
  Met à jour les données d’un client.

- **Entrées** :
  - `params[:id]` (Integer)
  - `params[:client]` (Hash)

- **Traitement** :
  - Recherche du client.
  - Tentative de mise à jour avec les nouveaux paramètres.

- **Sorties** :
  - Redirection vers `clients_path` avec un flash `notice` ou `alert`.
  - Vue `edit` en cas d’échec.

---

## `destroy`

- **Objectif** :  
  Supprime un client de la base de données.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Recherche du client puis suppression via `destroy`.

- **Sorties** :
  - Redirection vers la liste des clients avec message de confirmation ou d’échec.

---

## `generate_pdf`

- **Objectif** :  
  Génère un récapitulatif PDF des produits en dépôt associés à un client, avec les ventes et paiements liés.

- **Entrées** :
  - `params[:id]` (Integer)

- **Traitement** :
  - Récupère le client et ses produits en dépôt.
  - Pour chaque produit :
    - Vérifie s’il a été vendu.
    - Vérifie s’il a été payé (via jointure `PaiementsVente`).
  - Construit un tableau avec toutes les informations utiles.
  - Génère un fichier PDF avec `Prawn`.

- **Sorties** :
  - Envoie un fichier PDF au navigateur :
    - Nom : `recapitulatif_produits_<id>.pdf`
    - Type MIME : `application/pdf`
    - Disposition : `inline`

---

## Méthodes privées

### `set_client`

- **Objectif** :  
  Récupère et assigne l’instance client ciblée à `@client`.

- **Entrée** :
  - `params[:id]` (Integer)

- **Sortie** :
  - `@client` (Client)

---

### `client_params`

- **Objectif** :  
  Filtre les paramètres autorisés pour éviter toute injection de données non souhaitée.

- **Entrée** :
  - `params[:client]` (Hash)

- **Sortie** :
  - Paramètres filtrés (nom, prénom, email, téléphone, deposant, ancien_id)
