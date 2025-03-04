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

ActiveRecord::Schema[8.0].define(version: 2025_03_02_121844) do
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

  create_table "clients", force: :cascade do |t|
    t.string "nom"
    t.string "email"
    t.string "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deposant", default: false
    t.string "ancien_id"
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
    t.string "image"
    t.string "etat"
    t.boolean "en_depot", default: false
    t.boolean "occasion", default: false
    t.boolean "neuf", default: false
    t.integer "fournisseur_id"
    t.text "observation"
    t.integer "client_id"
    t.date "date_depot"
    t.decimal "prix_deposant", precision: 10, scale: 2
    t.boolean "vendu", default: false
  end

  create_table "ventes", force: :cascade do |t|
    t.integer "client_id", null: false
    t.decimal "prix_vendu"
    t.datetime "date_vente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total", precision: 10, scale: 2
    t.string "mode_paiement"
    t.index ["client_id"], name: "index_ventes_on_client_id"
  end

  create_table "ventes_produits", force: :cascade do |t|
    t.integer "vente_id", null: false
    t.integer "produit_id", null: false
    t.integer "quantite"
    t.decimal "prix_unitaire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["produit_id"], name: "index_ventes_produits_on_produit_id"
    t.index ["vente_id"], name: "index_ventes_produits_on_vente_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ventes", "clients"
  add_foreign_key "ventes_produits", "produits"
  add_foreign_key "ventes_produits", "ventes"
end
