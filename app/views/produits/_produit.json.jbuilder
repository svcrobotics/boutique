json.extract! produit, :id, :nom, :description, :prix, :etat, :stock, :created_at, :updated_at
json.url produit_url(produit, format: :json)
