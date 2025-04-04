# VentesController

Ce contrôleur gère l'ensemble du processus de vente : ajout d’articles, encaissement, impression du ticket, export mensuel, et statistiques.

---

## `index`

- **Objectif** :  
  Affiche la liste des ventes avec statistiques journalières et mensuelles.

- **Sorties** :
  - `@ventes` : liste des ventes récentes.
  - `@stats` : statistiques (`today_count`, `today_total`, `month_count`, `month_total`).
  - Vue : `ventes/index.html.erb`

---

## `show`

- **Objectif** :  
  Affiche le détail d'une vente.

- **Entrée** :
  - `params[:id]` (Integer)

---

## `new`

- **Objectif** :  
  Prépare une nouvelle vente via un panier temporaire stocké en session.  
  Permet d'ajouter un produit par code-barre ou afficher les produits sélectionnés.

- **Entrée** :
  - `params[:code_barre]` (optionnel)

- **Sorties** :
  - `@produits` et `@quantites` à afficher dans la vue.

---

## `recherche_produit`

- **Objectif** :  
  Ajoute un produit au panier via son code-barre.

- **Entrée** :
  - `params[:code_barre]`

- **Sorties** :
  - Mise à jour de la session `ventes`
  - Affichage dynamique via Turbo ou redirection

---

## `retirer_produit`

- **Objectif** :  
  Supprime un produit du panier temporaire.

- **Entrée** :
  - `params[:produit_id]`

---

## `modifier_quantite`

- **Objectif** :  
  Modifie la quantité d’un produit dans le panier temporaire.

- **Entrées** :
  - `params[:produit_id]`
  - `params[:quantite]`

---

## `create`

- **Objectif** :  
  Crée une vente complète à partir des produits en session.

- **Entrées** :
  - `params[:client_nom]` (optionnel)
  - `params[:mode_paiement]`
  - `session[:ventes]`

- **Traitement** :
  - Crée une vente, rattache les produits, calcule le total, met à jour le stock.
  - Vide la session.

- **Sorties** :
  - Redirection vers `ventes_path` avec message.

---

## `destroy`

- **Objectif** :  
  Supprime une vente.

- **Entrée** :
  - `params[:id]`

---

## `imprimer_ticket`

- **Objectif** :  
  Imprime un ticket de vente via une imprimante thermique.

- **Entrée** :
  - `params[:id]`

---

## `export_ventes`

- **Objectif** :  
  Exporte les ventes d’un mois donné au format Excel.

- **Entrées** :
  - `params[:mois]` (format YYYY-MM)

- **Sorties** :
  - Fichier `.xlsx` téléchargeable avec détail des lignes produits + totaux HT/TVA/TTC.

---

## 🔐 Méthodes privées

### `set_vente`

- Charge une vente via `params[:id]`.

### `vente_params`

- Strong params pour une vente + ses produits.

### `correct_scanner_input(input)`

- Convertit les caractères spéciaux scannés en chiffres corrects.

### `generer_ticket_texte(vente)`

- Construit un texte formaté pour le ticket (infos, lignes, totaux, TVA...).

### `encode_with_iconv(text)`

- Encode le texte du ticket pour l’impression en CP858.

### `imprimer_ticket_texte(vente)`

- Génère le ticket puis l’envoie à l’imprimante `ticket`.

