# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_20_191202) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "avoirs", force: :cascade do |t|
    t.integer "vente_id", null: false
    t.decimal "montant"
    t.date "date"
    t.boolean "utilise", default: false
    t.string "remarques"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "client_id"
    t.index ["client_id"], name: "index_avoirs_on_client_id"
    t.index ["vente_id"], name: "index_avoirs_on_vente_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "nom"
    t.string "email"
    t.string "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deposant", default: false
    t.string "ancien_id"
    t.string "prenom"
  end

  create_table "clotures", force: :cascade do |t|
    t.string "categorie"
    t.date "date"
    t.decimal "total_ht"
    t.decimal "total_tva"
    t.decimal "total_ttc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_ventes"
    t.integer "total_clients"
    t.decimal "ticket_moyen", precision: 10, scale: 2
    t.decimal "total_cb", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amex", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_especes", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_cheque", precision: 10, scale: 2, default: "0.0"
    t.decimal "ht_0", precision: 10, scale: 2, default: "0.0"
    t.decimal "ht_20", precision: 10, scale: 2, default: "0.0"
    t.decimal "ttc_0", precision: 10, scale: 2, default: "0.0"
    t.decimal "ttc_20", precision: 10, scale: 2, default: "0.0"
    t.decimal "tva_20", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_remises", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_annulations", precision: 10, scale: 2, default: "0.0"
    t.decimal "fond_caisse_initial", precision: 10, scale: 2, default: "0.0"
    t.decimal "fond_caisse_final", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_versements"
    t.decimal "total_encaisse"
    t.integer "total_articles"
    t.decimal "fond_de_caisse_final"
  end

  create_table "factures", force: :cascade do |t|
    t.string "numero"
    t.date "date"
    t.decimal "montant"
    t.integer "fournisseur_id", null: false
    t.string "fichier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fournisseur_id"], name: "index_factures_on_fournisseur_id"
  end

  create_table "fournisseurs", force: :cascade do |t|
    t.string "nom"
    t.string "email"
    t.string "telephone"
    t.text "adresse"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_fournisseur"
  end

  create_table "mouvement_especes", force: :cascade do |t|
    t.string "sens"
    t.string "motif"
    t.decimal "montant"
    t.date "date"
    t.string "compte"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "paiements", force: :cascade do |t|
    t.decimal "montant"
    t.date "date_paiement"
    t.string "methode_paiement"
    t.boolean "effectue"
    t.integer "numero_recu"
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_paiements_on_client_id"
  end

  create_table "paiements_ventes", force: :cascade do |t|
    t.integer "paiement_id", null: false
    t.integer "vente_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paiement_id"], name: "index_paiements_ventes_on_paiement_id"
    t.index ["vente_id"], name: "index_paiements_ventes_on_vente_id"
  end

  create_table "produits", force: :cascade do |t|
    t.string "nom"
    t.text "description"
    t.decimal "prix"
    t.integer "stock"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "categorie", default: "vêtement", null: false
    t.decimal "prix_achat", precision: 10, scale: 2
    t.date "date_achat"
    t.string "facture"
    t.string "etat"
    t.boolean "en_depot", default: false
    t.boolean "occasion", default: false
    t.boolean "neuf", default: false
    t.integer "fournisseur_id"
    t.text "observation"
    t.integer "client_id"
    t.date "date_depot"
    t.decimal "prix_deposant", precision: 10, scale: 2
    t.string "code_barre"
    t.boolean "impression_code_barre"
    t.string "code_fournisseur"
    t.boolean "vendu", default: false
    t.boolean "remise_fournisseur", default: false
    t.integer "taux_remise_fournisseur"
    t.boolean "en_promo"
    t.decimal "prix_promo"
  end

  create_table "produits_versements", force: :cascade do |t|
    t.integer "produit_id", null: false
    t.integer "versement_id", null: false
    t.integer "quantite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vente_id"
    t.decimal "montant_unitaire"
    t.index ["produit_id"], name: "index_produits_versements_on_produit_id"
    t.index ["vente_id"], name: "index_produits_versements_on_vente_id"
    t.index ["versement_id"], name: "index_produits_versements_on_versement_id"
  end

  create_table "reassorts", force: :cascade do |t|
    t.integer "produit_id", null: false
    t.integer "quantite"
    t.date "date"
    t.decimal "prix_achat"
    t.boolean "remise"
    t.integer "taux_remise"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["produit_id"], name: "index_reassorts_on_produit_id"
  end

  create_table "ventes", force: :cascade do |t|
    t.integer "client_id"
    t.decimal "prix_vendu"
    t.datetime "date_vente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total", precision: 10, scale: 2
    t.integer "versement_id"
    t.decimal "total_brut"
    t.decimal "total_net"
    t.boolean "annulee"
    t.string "motif_annulation"
    t.decimal "espece"
    t.decimal "cb"
    t.decimal "cheque"
    t.decimal "amex"
    t.index ["client_id"], name: "index_ventes_on_client_id"
    t.index ["versement_id"], name: "index_ventes_on_versement_id"
  end

  create_table "ventes_produits", force: :cascade do |t|
    t.integer "vente_id", null: false
    t.integer "produit_id", null: false
    t.integer "quantite"
    t.decimal "prix_unitaire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "remise"
    t.index ["produit_id"], name: "index_ventes_produits_on_produit_id"
    t.index ["vente_id"], name: "index_ventes_produits_on_vente_id"
  end

  create_table "ventes_versements", id: false, force: :cascade do |t|
    t.integer "versement_id", null: false
    t.integer "vente_id", null: false
  end

  create_table "versements", force: :cascade do |t|
    t.integer "client_id", null: false
    t.decimal "montant"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "methode_paiement"
    t.string "numero_recu"
    t.index ["client_id"], name: "index_versements_on_client_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "avoirs", "clients"
  add_foreign_key "avoirs", "ventes"
  add_foreign_key "factures", "fournisseurs"
  add_foreign_key "paiements", "clients"
  add_foreign_key "paiements_ventes", "paiements"
  add_foreign_key "paiements_ventes", "ventes"
  add_foreign_key "produits_versements", "produits"
  add_foreign_key "produits_versements", "versements"
  add_foreign_key "reassorts", "produits"
  add_foreign_key "ventes", "clients"
  add_foreign_key "ventes", "versements"
  add_foreign_key "ventes_produits", "produits"
  add_foreign_key "ventes_produits", "ventes"
  add_foreign_key "versements", "clients"
end
