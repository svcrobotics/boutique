json.extract! vente, :id, :produit_id, :client_id, :prix_vendu, :date_vente, :created_at, :updated_at
json.url vente_url(vente, format: :json)
