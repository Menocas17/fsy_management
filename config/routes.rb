Rails.application.routes.draw do
  # En el VPS el proxy atiende también el www y la dirección vieja de sslip.io (config/deploy.yml): todo eso se
  # manda a APP_HOST para que la sesión y la app instalada vivan en un solo dominio. /up queda afuera porque el
  # proxy revisa la salud del contenedor con otro host.
  if Rails.env.production? && (canonical_host = ENV["APP_HOST"].presence)
    constraints(->(request) { request.host != canonical_host && request.path != "/up" }) do
      match "(*path)", via: :all, to: redirect(status: 301) { |_params, request| "https://#{canonical_host}#{request.fullpath}" }
    end
  end

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
  post "accesos/acceso-total" => "accesses#grant_full_access", as: :access_full_access_grants
  delete "accesos/acceso-total/:id" => "accesses#revoke_full_access", as: :access_full_access_grant
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
  # El tutorial: empezarlo (manda la alerta de práctica y devuelve los pasos) y terminarlo o saltarlo.
  resource :tutorial, only: %i[create update], path: "tutorial"
  get "escanear" => "scans#show", as: :scan
  get "escanear/buscar" => "scans#lookup", as: :scan_lookup

  # Registro de llegadas: la pantalla de escaneo, el padrón que se guarda en el dispositivo y la sincronización.
  get "registro" => "checkins#index", as: :checkins
  get "registro/padron" => "checkins#roster", as: :checkins_roster
  get "registro/registrados" => "checkins#registered", as: :registered_checkins
  post "registro" => "checkins#create", as: :register_checkins
  patch "registro/finalizar" => "checkins#finish", as: :finish_checkins
  delete "registro/finalizar" => "checkins#reopen"
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
      get :birthdays, path: "cumpleaneros"
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
      post "suscripcion/prueba" => "push_subscriptions#send_test", as: :push_test
    end
  end
  resources :alerts, only: [ :index, :show, :new, :create, :destroy ], path: "alertas"
  resource :agenda, only: [ :show ], controller: "agenda"
  # El detalle de una actividad en el acordeón del teléfono: se pide al abrirlo (AgendaController#activity).
  get "agenda/actividades/:id" => "agenda#activity", as: :agenda_activity
  resources :activities, only: [ :new, :create, :edit, :update, :destroy ], path: "actividades"
  get "novedades" => "changelog#index", as: :changelog
  # Manuales: los PDF del FSY (subirlos o quitarlos, por clase) y los enlaces a la Biblioteca del Evangelio.
  resource :manuals, only: :show, path: "manuales" do
    get :links, path: "enlaces"
    patch :links, action: :update_links, path: "enlaces"
  end
  constraints(kind: /joven|lideres/) do
    get "manuales/:kind/leer" => "manuals#read", as: :read_manual
    patch "manuales/:kind" => "manuals#upload", as: :upload_manual
    delete "manuales/:kind" => "manuals#remove", as: :remove_manual
  end
  # «Mi compañía» del joven; al consejero y al auxiliar los lleva a la suya (DashboardHelper#my_company_link).
  get "mi-compania" => "my_companies#show", as: :my_company
  get "instalar-app" => "install_sheets#show", as: :install_sheet
  resource :settings, only: [ :show ] do
    patch :scan_windows
    patch :simple_mode
    patch :company_reveal
    patch :view_as_access
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
  # Cuartos: el tablero, la propuesta del ordenamiento (?semilla=, ?llegados=1) y aplicarla, y la configuración
  # del hotel (sus pasillos y cuartos). Van antes de cuartos/:id, que si no se las tragaría.
  resource :room_plan, only: %i[show create], path: "cuartos/ordenar"
  resources :hallways, except: :show, path: "cuartos/pasillos", path_names: { new: "nuevo", edit: "editar" } do
    post :load_layout, on: :collection, path: "cargar-hotel"
  end
  resources :rooms, only: %i[index show], path: "cuartos"
  # El panel: qué compañías ya pasaron la asistencia nocturna y quién falta.
  resources :night_attendances, only: :index, path: "asistencia-nocturna"
  # El seguimiento de las asignaciones delegadas; quien recibe una la confirma.
  resources :assignments, only: [ :index, :update, :destroy ], path: "asignaciones" do
    patch :confirm, on: :member, path: "confirmar"
  end
  # Compañías sugeridas para un joven que se registra sin compañía (CompanySuggester): en su ficha y en el formulario.
  get "companias/sugerencias" => "company_suggestions#show", as: :company_suggestions
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
