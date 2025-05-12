# 📘 README - Application de Gestion Boutique Dépôt-Vente

Cette application Ruby on Rails permet de gérer une boutique physique de prêt-à-porter en dépôt-vente, avec encaissement, suivi des stocks, versements aux déposants, impression de tickets, clôtures journalières et mensuelles, et export comptable.

---

## 🧾 FONCTIONNALITÉS DE LA CAISSE (VENTES)

### ✅ Fait :

- Encaissement multi-produits (scan ou clic)
- Gestion des modes de paiement : espèces, CB, AMEX, chèque
- Calcul automatique du total TTC
- Remises **par produit** (montant ou pourcentage)
- Gestion de la quantité par produit
- Affichage clair du ticket en cours (Turbo Frame)
- Enregistrement de la vente en BDD
- Impression du ticket de caisse
- Vente avec ou sans cliente
- Autocomplétion cliente ou création rapide via formulaire Turbo
- Saisie du prix manuel possible si prix_vendu est vide
- Gestion des ventes de produits d’occasion, dépôt-vente et neufs

### 🔄 À faire :

- Remise **globale** sur toute la vente
- Gestion des retours/remboursements
- Duplication d’une vente précédente (optionnelle)

### 💡 À envisager :

- Historique des ventes par cliente
- Gestion de paniers sauvegardés (cas client hésitant ou retour plus tard)

---

## 📦 GESTION DES PRODUITS

### ✅ Fait :

- Création d’un produit neuf, d’occasion ou en dépôt
- Champs gérés : nom, description, stock, prix achat, prix vente, prix déposant, image, code-barres, état, catégorie
- Saisie facilitée par Turbo avec affichage du bon formulaire selon le type (neuf, occasion, dépôt)
- Upload image via Active Storage
- Impression d’étiquettes code-barres (DYMO)
- Recalcul automatique des marges selon l’état du produit

### 🔄 À faire :

- Gestion des variantes (ex : tailles, couleurs)
- Historique des mouvements de stock

### 💡 À envisager :

- Fusion de doublons
- Produits favoris / bestsellers

---

## 👤 GESTION CLIENTS

### ✅ Fait :

- Distinction client simple / client déposant
- Saisie simplifiée des informations principales
- Visualisation des produits déposés, vendus, payés, en attente
- Impression d’un reçu de versement
- Génération d’un PDF client (produits vendus, montants dus, etc.)

### 🔄 À faire :

- Recherche avancée (par mail, téléphone, historique)
- Gestion des notifications par mail

### 💡 À envisager :

- Espace client en ligne (future sync e-commerce)

---

## 💰 VERSEMENTS / PAIEMENTS DÉPOSANTS

### ✅ Fait :

- Calcul automatique des produits à verser (produit par vente)
- Versements multiples possibles par produit/vente
- Impression du ticket de versement
- Gestion du mode de paiement
- Historique des paiements effectués
- Prévisualisation du ticket avant versement

### 🔄 À faire :

- Ajout manuel de ligne exceptionnelle
- Gestion des retenues (ex : commission exceptionnelle)

### 💡 À envisager :

- Paiement par virement avec génération d’un fichier SEPA

---

## 📊 CLÔTURES JOURNALIÈRES ET MENSUELLES

### ✅ Fait :

- Calcul des totaux journaliers : HT, TTC, TVA, remises, espèces, CB, AMEX, chèques, ventes, clients, ticket moyen
- Ticket Z journalier imprimable
- Clôture mensuelle regroupant les Z du mois
- Impression d’un ticket Z mensuel (synthèse)
- Calcul du fond de caisse théorique et comparaison avec le compté
- Récapitulatif des versements et ventes

### 🔄 À faire :

- Visualisation graphique des ventes (par jour, semaine…)
- Clôture automatique si oubli

### 💡 À envisager :

- Envoi automatique à la comptable (PDF ou Excel)

---

## 🖨️ IMPRESSION

### ✅ Fait :

- Ticket de caisse avec détails produits, remises, mode de paiement
- Ticket versement
- Ticket clôture Z
- Impression DYMO pour étiquettes code-barres produits
- Conversion automatique UTF-8 → CP858 pour compatibilité imprimantes

### 🔄 À faire :

- Mise en forme conditionnelle (ex : couleur promo si promo active)

### 💡 À envisager :

- Choix de l’imprimante dynamique (ticket ou A4)

---

## ⚙️ ADMINISTRATION / PARAMÈTRES

### ✅ Fait :

- Ajout de produits via `rails console`, `seed` ou interface
- Gestion des fournisseurs (produits neufs, occasions, ventes)
- Distinction produit occasion / neuf / dépôt avec logique différente

### 🔄 À faire :

- Interface admin dédiée (paramétrage, historique)
- Gestion des rôles utilisateurs (admin, caisse…)

### 💡 À envisager :

- Synchronisation automatique du stock avec une boutique en ligne

---

## 📡 SYNCHRONISATION E-COMMERCE (À VENIR)

### 💡 Prévu :

- Application publique Shopify-like hébergée sur Gandi
- Tous les produits synchronisés depuis l’app boutique (pas de création côté e-commerce)
- Images, description, stock en lecture seule côté client

---

## ✨ À suivre...

- Ajout des fonctionnalités d’import / export comptable
- Génération de fichier Excel pour la comptable
- Sauvegarde automatique / plan de restauration
- Monitoring / rapport d’erreurs

## 🛠️ Stack technique

- Ruby 3.4.1  
- Rails 8.0.1  
- Hotwire (Turbo + Stimulus)  
- Tailwind CSS  
- SQLite (dev) → PostgreSQL (prod recommandé)

---

## 📸 Captures d’écran 

Voici quelques écrans de l'application Boutique :

![Liste des produits](app/assets/images/)
![Encaissement](app/assets/images/)

---

## 🔒 Projet privé

Ce projet est en cours de développement en vue d’une commercialisation.  
Si vous êtes intéressé pour devenir **client bêta** ou pour en discuter, contactez-moi.

---

## 📩 Contact

Victor – Développeur indépendant  
📧 svcrobotics@gmail.com
