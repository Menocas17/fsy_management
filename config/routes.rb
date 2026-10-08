Rails.application.routes.draw do
  mount RailsIcons::Engine, at: "/rails_icons"
  resource :session
  resources :passwords, param: :token
  # Cambiar la contraseña ya adentro, con la actual: no depende del correo.
  resource :password_change, only: %i[edit update], path: "contrasena", path_names: { edit: "cambiar" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # La subida directa de Active Storage, pero con sesión y solo imágenes (DirectUploadsController). Va antes que
  # la ruta de fábrica, que queda tapada.
  post "rails/active_storage/direct_uploads" => "direct_uploads#create", as: :direct_uploads

  # PWA: el manifest permite instalar la app y el service worker recibe las notificaciones push.
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "sessions#new"
  resource :dashboard, only: [ :show ]
  resource :organigrama, only: [ :show ], controller: "organigrama"
  resources :audit_logs, only: [ :index ], path: "historial"
  # Quién está en línea, sus sesiones abiertas y los intentos de entrar: solo para el superadmin.
  resources :accesses, only: [ :index ], path: "accesos"
  # «Ver como» otra persona (su menú y sus permisos): solo el superadmin.
  resource :view_as, only: %i[create destroy], controller: "view_as", path: "ver-como"
  delete "accesos/sesiones/:id" => "accesses#destroy_session", as: :access_session
  # Finanzas: el panel y su configuración, las categorías y los gastos con sus tres etapas (docs/finanzas.md).
  resource :finances, only: %i[show edit update], path: "finanzas", path_names: { edit: "configurar" }
  resources :expense_categories, only: %i[new create edit update destroy], path: "finanzas/categorias",
                                 path_names: { new: "nueva", edit: "editar" }
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
  # La búsqueda de toda la app (botón central de la barra inferior del modo simple).
  get "buscar" => "searches#show", as: :search
  get "escanear" => "scans#show", as: :scan
  get "escanear/buscar" => "scans#lookup", as: :scan_lookup

  # Registro de llegadas: la pantalla de escaneo, el padrón que se guarda en el dispositivo y la sincronización.
  get "registro" => "checkins#index", as: :checkins
  get "registro/padron" => "checkins#roster", as: :checkins_roster
  post "registro" => "checkins#create", as: :register_checkins
  # Áreas de logística: sus banderas (Registro, Finanzas, Alimentación) y sus miembros.
  resources :logistics_areas, path: "areas", path_names: { new: "nueva", edit: "editar" } do
    resources :members, only: %i[create destroy], controller: "logistics_area_members", path: "miembros"
  end

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
      get :expenses, path: "gastos"
      get :expenses_workbook, path: "gastos-excel"
    end
  end
  # Carga masiva: subir el archivo y, de cada carga, su informe con las filas que esperan resolverse a mano.
  # Las compañías se suben aparte (no dejan informe: cada fila entra o dice por qué no).
  post "carga-de-participantes/companias", to: "company_imports#create", as: :company_imports
  resources :participant_imports, only: %i[new create show], path: "carga-de-participantes", path_names: { new: "subir" } do
    resources :rows, only: %i[edit update], controller: "participant_import_rows", path: "filas", path_names: { edit: "corregir" } do
      member do
        patch :approve, path: "aprobar"
        patch :discard, path: "descartar"
      end
    end
  end
  resources :notifications, only: [ :index, :destroy ], path: "notificaciones" do
    collection do
      delete "limpiar" => "notifications#clear", as: :clear
      # La campanita pregunta por su número cuando vuelve de la caché de Turbo, donde viene congelado.
      get "campanita" => "notifications#count", as: :count
      # Lo de adentro del menú de la campanita: se pide al abrirlo, no en cada página.
      get "menu" => "notifications#menu", as: :menu
      # Abrir el menú de la campanita cuenta como leerlas, igual que abrir la página.
      patch "leidas" => "notifications#read", as: :read
      post "suscripcion" => "push_subscriptions#create", as: :push_subscription
      delete "suscripcion" => "push_subscriptions#destroy"
    end
  end
  resources :alerts, only: [ :index, :show, :new, :create, :destroy ], path: "alertas"
  resource :agenda, only: [ :show ], controller: "agenda"
  # El detalle de una actividad en el acordeón del teléfono: se pide al abrirlo (AgendaController#activity).
  get "agenda/actividades/:id" => "agenda#activity", as: :agenda_activity
  resources :activities, only: [ :new, :create, :edit, :update, :destroy ], path: "actividades"
  get "novedades" => "changelog#index", as: :changelog
  resource :settings, only: [ :show ] do
    patch :scan_windows
    patch :simple_mode
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
    # La lista de la noche de esta compañía (?genero=H|M): la pasa su consejero, la ven los del panel.
    resource :night_attendance, only: %i[show update], path: "asistencia-nocturna"
  end
  # Enfermería: el tablero en vivo, ingresar (o avisar que lo llevan), confirmar la entrada, dar de alta,
  # las notas de la ficha clínica y la ficha de cada joven con todas sus visitas.
  resources :infirmary_visits, only: %i[index new create destroy], path: "enfermeria", path_names: { new: "ingresar" } do
    member do
      patch :admit, path: "confirmar"
      patch :discharge, path: "alta"
    end
    resources :notes, only: :create, controller: "infirmary_notes", path: "notas"
  end
  get "enfermeria/fichas/:participant_id" => "infirmary_charts#show", as: :infirmary_chart
  # El panel: qué compañías ya pasaron la asistencia nocturna y quién falta.
  resources :night_attendances, only: :index, path: "asistencia-nocturna"
  resources :assignments, only: [ :update, :destroy ], path: "asignaciones"
  # El QR de una ficha, para el diálogo «Mi QR» de la barra inferior (se pide al abrirlo).
  get "participants/:participant_id/qr" => "participant_qrs#show", as: :participant_qr
  resources :participants do
      resources :assignments, only: [ :new, :create ], path: "asignaciones"
      # Crear la cuenta de la ficha (POST) o restablecerla (PATCH); en los dos casos le llega un enlace por correo.
      resource :account, only: %i[create update], controller: "participant_accounts", path: "cuenta"
      collection do
        get :staff
        get :myprofile
      end
  end
end
