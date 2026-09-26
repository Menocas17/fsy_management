Rails.application.routes.draw do
  mount RailsIcons::Engine, at: "/rails_icons"
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "sessions#new"
  resource :dashboard, only: [ :show ]
  resource :organigrama, only: [ :show ], controller: "organigrama"
  resources :audit_logs, only: [ :index ], path: "historial"
  resources :inventories, only: %i[index show new create edit update destroy], path: "inventario" do
    collection do
      get :scan, path: "escanear"
    end
    resources :items, only: %i[new create], controller: "inventory_items", path: "articulos"
  end
  # El código del artículo es su identificador en la URL, así el QR lleva directo a su ficha.
  resources :inventory_items, only: %i[show edit update], path: "articulos" do
    collection do
      get :lookup, path: "buscar"
    end
    resources :movements, only: [ :create ], controller: "inventory_movements", path: "movimientos"
  end
  resources :reports, only: [ :index ], path: "reportes" do
    collection do
      get :participants, path: "participantes"
      get :rooms, path: "cuartos"
      get :agenda
      get :inventory, path: "inventario"
      get :labels, path: "etiquetas"
    end
  end
  resource :participant_import, only: [ :new, :create ], path: "carga-de-participantes"
  resources :notifications, only: [ :index ], path: "notificaciones"
  resources :alerts, only: [ :index, :show, :new, :create, :destroy ], path: "alertas"
  resource :agenda, only: [ :show ], controller: "agenda"
  resources :activities, only: [ :new, :create, :edit, :update, :destroy ], path: "actividades"
  resource :settings, only: [ :show ] do
    post :send_password_reset
  end
  resources :auxiliar_companies do
    member do
      post :assign_staff
      delete :remove_staff
    end
  end
  resources :companies do
    collection do
      get :overview
    end
    member do
      post :assign_staff
      delete :remove_staff
    end
  end
  resources :assignments, only: [ :update, :destroy ], path: "asignaciones"
  resources :participants do
      resources :assignments, only: [ :new, :create ], path: "asignaciones"
      collection do
        get :staff
        get :myprofile
      end
      member do
        post :send_password_reset
      end
  end
end
