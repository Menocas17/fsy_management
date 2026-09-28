Rails.application.routes.draw do
  mount RailsIcons::Engine, at: "/rails_icons"
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA: el manifest permite instalar la app y el service worker recibe las notificaciones push.
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "sessions#new"
  resource :dashboard, only: [ :show ]
  resource :organigrama, only: [ :show ], controller: "organigrama"
  resources :audit_logs, only: [ :index ], path: "historial"
  # Finanzas: el panel y su configuración, las categorías y los gastos con sus tres etapas (docs/finanzas.md).
  resource :finances, only: %i[show edit update], path: "finanzas", path_names: { edit: "configurar" }
  resources :expense_categories, only: %i[create update destroy], path: "finanzas/categorias"
  resources :expenses, path: "finanzas/gastos", path_names: { new: "presentar", edit: "editar" } do
    member do
      patch :approve, path: "aprobar"
      patch :reject, path: "rechazar"
      patch :withdraw, path: "retirar"
      patch :consolidate, path: "consolidar"
      patch :justify, path: "justificar"
      patch :approve_justification, path: "aprobar-justificacion"
      patch :reject_justification, path: "rechazar-justificacion"
    end
  end
  # El resumen de capacitaciones vive dentro de la agenda, que es donde se buscan las fechas.
  scope path: "agenda", as: :agenda do
    resources :trainings, path: "capacitaciones", path_names: { new: "nueva", edit: "editar" } do
      resources :attendances, only: %i[create destroy], controller: "training_attendances", path: "asistencia"
    end
  end

  # Lector general del panel: un gafete abre la ficha de la persona; un artículo, su ficha de inventario.
  get "escanear" => "scans#show", as: :scan
  get "escanear/buscar" => "scans#lookup", as: :scan_lookup

  # Registro de llegadas: la pantalla de escaneo, el padrón que se guarda en el dispositivo y la sincronización.
  get "registro" => "checkins#index", as: :checkins
  get "registro/padron" => "checkins#roster", as: :checkins_roster
  post "registro" => "checkins#create", as: :register_checkins
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
      get :badges, path: "gafetes"
      get :inventory, path: "inventario"
      get :labels, path: "etiquetas"
      get :trainings, path: "capacitaciones"
    end
  end
  resource :participant_import, only: [ :new, :create ], path: "carga-de-participantes"
  resources :notifications, only: [ :index ], path: "notificaciones" do
    collection do
      # La campanita pregunta por su número cuando vuelve de la caché de Turbo, donde viene congelado.
      get "campanita" => "notifications#count", as: :count
      post "suscripcion" => "push_subscriptions#create", as: :push_subscription
      delete "suscripcion" => "push_subscriptions#destroy"
    end
  end
  resources :alerts, only: [ :index, :show, :new, :create, :destroy ], path: "alertas"
  resource :agenda, only: [ :show ], controller: "agenda"
  resources :activities, only: [ :new, :create, :edit, :update, :destroy ], path: "actividades"
  resource :settings, only: [ :show ] do
    post :send_password_reset
    patch :scan_windows
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
