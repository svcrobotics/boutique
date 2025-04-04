# CloturesController

Ce contrôleur gère les clôtures de caisse journalières, incluant le calcul des ventes, des paiements, de la TVA, et l'impression d'un ticket Z.

---

## `index`

- **Objectif** :  
  Affiche la liste des clôtures journalières déjà enregistrées dans la base de données.

- **Entrées** :  
  Aucune.

- **Traitement** :
  - Récupère toutes les clôtures et les trie par date décroissante (`date DESC`).

- **Sorties** :
  - `@clotures` (Array<Cloture>) : Liste des clôtures ordonnée.
  - Vue HTML : `clotures/index.html.erb`

---

## `cloture_z`

- **Objectif** :  
  Effectue la clôture de caisse journalière (Ticket Z), en :
  - Vérifiant qu’aucune clôture n’existe déjà pour le jour courant.
  - Calculant les montants encaissés par mode de paiement.
  - Calculant les montants HT, TVA et TTC en fonction des taux de TVA.
  - Enregistrant les résultats dans la table `clotures`.
  - Générant et imprimant un ticket Z.

- **Entrées** :
  - Date actuelle via `Date.current`.

- **Traitement** :
  1. Vérifie l’absence de clôture "journalier" pour aujourd’hui.
  2. Récupère toutes les ventes du jour (`created_at: jour.all_day`), incluant les produits vendus.
  3. Calcule :
     - Nombre de ventes
     - Nombre total d’articles vendus
     - Totaux encaissés par mode de paiement : espèces, CB, chèque
     - Totaux TTC à 0% (occasion) et à 20% (neuf)
     - Dérive HT et TVA à partir des TTC
  4. Crée une nouvelle `Cloture` avec les totaux HT, TVA, TTC.
  5. Génère un tableau texte :
     - Détail des ventes, modes de paiement, récapitulatif TVA
  6. Encode le ticket pour l’imprimante (CP858) et l’imprime via la commande `lp`.

- **Sorties** :
  - Enregistrement en base : nouvelle ligne dans la table `clotures`.
  - Impression : fichier texte CP858 envoyé à l’imprimante `ticket`.
  - Redirection vers `ventes_path` avec message de confirmation ou d'erreur.

---

## 💡 Notes techniques

- Le champ `categorie` de la table `clotures` contient la valeur `"journalier"` pour identifier les tickets Z.
- Le format CP858 est requis pour l'impression sur imprimante thermique avec caractères accentués.
- L'impression utilise la commande système `lp -d ticket`.

