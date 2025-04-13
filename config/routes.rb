Rails.application.routes.draw do
  root "pages#home"
  resources :fournisseurs
  resources :factures

  resources :paiements do
    member do
      post :lier_aux_ventes
      get :imprimer
    end
  end

  resources :clients do
    resources :paiements, only: [ :index, :new, :create ]
    member do
      get :generate_pdf
    end
  end

  get "ventes/export", to: "ventes#export_ventes", as: :export_ventes
  get "ventes/export_interface", to: "ventes#index", as: :export_interface_ventes

  resources :ventes do
    post :recherche_produit, on: :collection
    post :retirer_produit, on: :collection
    post :modifier_quantite, on: :collection
    post :modifier_prix, on: :collection
    get :imprimer_ticket, on: :member
  end

  resources :clients do
    resources :versements, only: [ :new, :create ]
  end

  resources :versements, only: [ :index ] do
    get :imprimer, on: :member
  end

  get "stats", to: "stats#index"

  resources :clotures do
    get :imprimer, on: :member
    get :preview, on: :member
    post :cloture_z, on: :collection
    post :cloture_mensuelle, on: :collection
  end

  resources :produits do
    member do
      post :generate_label
      get "supprimer_photo/:photo_id", action: :supprimer_photo, as: :supprimer_photo
    end

    collection do
      post :generate_multiple_labels
    end
  end

  get "turbo_demo", to: "pages#turbo_demo"

  # get "texte", to: "textes#show", as: :texte

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
