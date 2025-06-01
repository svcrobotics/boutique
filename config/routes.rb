Rails.application.routes.draw do
  namespace :caisse do
    get "remboursements/index"
  end
  
  get "reassorts/new"
  get "reassorts/create"
  get "especes/index"
  get "especes/new"
  get "especes/create"

  root "pages#home"

  resources :avoirs, only: [:index, :show] do
    post :imprimer, on: :member
  end

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

  # get "ventes/export", to: "ventes#export_ventes", as: :export_ventes
  # get "ventes/export_interface", to: "ventes#index", as: :export_interface_ventes


  resources :clients do
    resources :versements, only: [ :new, :create ]
  end

  resources :versements, only: [ :index ] do
    get :imprimer, on: :member
  end

  get "stats", to: "stats#index"


  resources :produits do
    member do
      post :generate_label
      get "supprimer_photo/:photo_id", action: :supprimer_photo, as: :supprimer_photo
    end

    collection do
      post :generate_multiple_labels
    end

    resources :reassorts, only: [:new, :create] do
      post :imprimer_etiquettes, on: :member
    end
  end

  get "turbo_demo", to: "pages#turbo_demo"

  # post "ventes/modifier_remise", to: "ventes#modifier_remise", as: :modifier_remise_ventes

  resources :especes, only: [:index, :new, :create]

  mount Caisse::Engine => "/caisse"

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
