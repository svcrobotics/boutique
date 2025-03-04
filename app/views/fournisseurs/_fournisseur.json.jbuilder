json.extract! fournisseur, :id, :nom, :email, :telephone, :adresse, :created_at, :updated_at
json.url fournisseur_url(fournisseur, format: :json)
