module NavigationHelper
  # El menú lateral y el cajón del teléfono comparten esta estructura: «Inicio» suelto y luego grupos
  # desplegables (shared/_nav_sections + nav_groups_controller). Cada grupo tiene un id estable: con él se
  # recuerda en el dispositivo si la persona lo dejó abierto o cerrado.
  # Se arma una vez por petición: lo usan el menú lateral, el cajón y el «Más» del modo simple.
  def nav_sections
    @nav_sections ||= build_nav_sections
  end

  def build_nav_sections
    sections = [
      { id: nil, label: nil, items: [
        { text: "Inicio", url: dashboard_path, lucide_icon: "house" }
      ] },
      { id: "participantes", label: "Participantes", items: [
        { text: "Jóvenes", url: participants_path, lucide_icon: "users", section: "jovenes",
          active_paths: [ participants_path ], except_paths: [ staff_participants_path, myprofile_participants_path ] },
        { text: "Staff", url: staff_participants_path, lucide_icon: "user-check", section: "staff",
          active_paths: [ staff_participants_path ] },
        { text: "Compañías", url: companies_path, lucide_icon: "building-2", section: "companies", active_paths: [ companies_path, auxiliar_companies_path ] },
        { text: "Organigrama", url: organigrama_path, lucide_icon: "network" }
      ] },
      { id: "evento", label: "Evento", items: [
        { text: "Agenda", url: agenda_path, lucide_icon: "calendar-days", active_paths: [ agenda_path, activities_path ] },
        # El registro de llegadas solo aparece para el comité que lo hace.
        ({ text: "Registro", url: checkins_path, lucide_icon: "scan-line", active_paths: [ checkins_path ] } if Current.user&.checkin_registrar?),
        ({ text: "Alertas", url: alerts_path, lucide_icon: "megaphone", active_paths: [ alerts_path ] } if Current.user&.alert_manager?)
      ] },
      { id: "logistica", label: "Logística", items: [
        ({ text: "Áreas", url: logistics_areas_path, lucide_icon: "layout-grid", active_paths: [ logistics_areas_path ] } if Current.user&.logistics_areas_manager?),
        # Las fichas de artículo cuelgan de /articulos, fuera de /inventario.
        ({ text: "Inventario", url: inventories_path, lucide_icon: "boxes",
           active_paths: [ inventories_path, "/articulos" ] } if Current.user&.inventory_member?),
        ({ text: "Finanzas", url: finances_path, lucide_icon: "wallet", active_paths: [ finances_path ] } if Current.user&.finance_viewer?)
      ] },
      { id: "seguimiento", label: "Seguimiento", items: [
        ({ text: "Reportes", url: reports_path, lucide_icon: "file-text",
           active_paths: [ reports_path, participant_imports_path ] } if Current.user&.reports_viewer?),
        night_attendance_nav_item,
        ({ text: "Enfermería", url: infirmary_visits_path, lucide_icon: "heart-pulse",
           active_paths: [ infirmary_visits_path ] } if Current.user&.infirmary_viewer?),
        ({ text: "Historial", url: audit_logs_path, lucide_icon: "clipboard-clock" } if Current.user&.admin_or_staff_manager?)
      ] }
    ]
    # Cada quien ve solo lo que puede abrir: un módulo sin acceso no aparece en gris, se omite. "Mi perfil"
    # vive en el menú de cuenta de la barra superior; un grupo que queda sin opciones se omite entero.
    sections.filter_map do |section|
      items = section[:items].compact.map { |item| item.merge(is_nav: true) }
      section.merge(items: items, active: items.any? { |item| nav_item_active?(**item) }) if items.any?
    end
  end

  # Modo simple (User#simple_mode?): en el teléfono la barra inferior reemplaza al menú lateral.
  def simple_mode?
    Current.user&.simple_mode? || false
  end

  # Las cuatro opciones de la barra inferior alrededor del botón central: Inicio, lo propio de cada rol y
  # Agenda; la cuarta es «Más» (simple_more_items).
  def simple_bar_items
    [
      { text: "Inicio", url: dashboard_path, icon: "house" },
      simple_own_item,
      { text: "Agenda", url: agenda_path, icon: "calendar-days", active_paths: [ agenda_path, activities_path ] }
    ].map { |item| item.merge(active: nav_item_active?(url: item[:url], active_paths: item.fetch(:active_paths, []))) }
  end

  # Lo de cada rol: su compañía, las de su rama, las de todos o el módulo de su área de logística.
  def simple_own_item
    participant = Current.user.participant
    case participant&.rol
    when "consejero"
      company = participant.counselor_scope.first
      return { text: "Mi compañía", url: company_path(company), icon: "building-2" } if company
    when "auxiliar"
      auxiliar_company = participant.auxiliar_scope[:auxiliar_company]
      return { text: "Compañías", url: auxiliar_company_path(auxiliar_company), icon: "building-2" } if auxiliar_company
    when "director_logistica"
      return { text: "Logística", url: logistics_areas_path, icon: "layout-grid", active_paths: [ logistics_areas_path ] }
    when "logistica"
      return simple_area_item(participant.logistics_area)
    end
    { text: "Compañías", url: companies_path, icon: "building-2", active_paths: [ companies_path, auxiliar_companies_path ] }
  end

  # Logística entra al módulo que su área trabaja; sin bandera, al inventario (que mueve toda logística).
  def simple_area_item(area)
    if area&.checkin? then { text: "Registro", url: checkins_path, icon: "scan-line", active_paths: [ checkins_path ] }
    elsif area&.nursing? then { text: "Enfermería", url: infirmary_visits_path, icon: "heart-pulse", active_paths: [ infirmary_visits_path ] }
    elsif area&.finance? then { text: "Finanzas", url: finances_path, icon: "wallet", active_paths: [ finances_path ] }
    else { text: "Inventario", url: inventories_path, icon: "boxes", active_paths: [ inventories_path, "/articulos" ] }
    end
  end

  # Acceso total en el teléfono va a lo que pasa durante la semana; lo demás lo trabaja en la computadora.
  FULL_ACCESS_MORE_ITEMS = [ "Alertas", "Enfermería", "Asistencia nocturna" ].freeze

  # «Más»: el resto del menú que la persona puede abrir (lo que ya está en la barra no se repite) y el
  # escáner de gafetes; para acceso total, solo FULL_ACCESS_MORE_ITEMS. Configuración, Mi perfil y Cerrar sesión
  # siguen en el menú de la foto.
  def simple_more_items
    in_bar = simple_bar_items.map { |item| URI.parse(item[:url]).path }
    items = nav_items.reject { |item| in_bar.include?(URI.parse(item[:url]).path) }
                     .map { |item| { text: item[:text], url: item[:url], icon: item[:lucide_icon] } }
    if Current.user.full_access?
      items = FULL_ACCESS_MORE_ITEMS.filter_map { |text| items.find { |item| item[:text] == text } }
    end
    [ { text: "Escanear gafete", url: scan_path, icon: "scan-qr-code" }, *items ]
  end

  # El panel para quienes lo siguen; al consejero lo lleva directo a la lista de su compañía.
  def night_attendance_nav_item
    if Current.user&.night_attendance_viewer?
      { text: "Asistencia nocturna", url: night_attendances_path, lucide_icon: "moon-star", active_paths: [ night_attendances_path ] }
    elsif Current.user&.participant&.consejero? && (company = Current.user.participant.counselor_scope.first)
      { text: "Asistencia nocturna", url: company_night_attendance_path(company), lucide_icon: "moon-star" }
    end
  end

  # Un grupo arranca abierto salvo que la persona lo haya cerrado (cookie de nav_groups_controller); el de
  # la página abierta, siempre abierto.
  def nav_group_open?(section)
    section[:active] || !cookies[:fsy_nav_closed].to_s.split(".").include?(section[:id])
  end

  # Si una opción del menú es la página abierta. La usan ButtonComponent (para pintarla) y los grupos (para
  # abrir siempre el que la contiene). active_paths la mantiene encendida en sus páginas anidadas (nueva,
  # editar, ver); except_paths evita que se encienda una hermana (Jóvenes y Staff viven bajo /participants).
  def nav_item_active?(url: nil, section: nil, active_paths: [], except_paths: [], disabled: false, **)
    return false if disabled || url.nil?
    # A ?from= param says which list the person came from, and that wins over path matching.
    return section.present? && params[:from] == section if params[:from].present?
    # Lo que cuelga de una ficha (la ficha, editarla, su nueva asignación) es de Jóvenes o de Staff según su rol.
    return section.present? && participant_nav_section == section if participant_nav_section
    return true if current_page?(url)
    return false if except_paths.any? { |path| request.path.start_with?(path) }

    active_paths.any? { |path| request.path.start_with?(path) }
  end

  def nav_items
    nav_sections.flat_map { |section| section[:items] }
  end

  # Cada vista de detalle dice a dónde vuelve y la barra superior lo pinta siempre en el mismo lugar,
  # así nadie depende de las flechas del navegador.
  def back_to(label, url)
    # En el teléfono el volver no es este botón: la barra superior cambia el menú por «‹ label» (page_back).
    @page_back = { label: label, url: url }
    content_for :back do
      link_to url, title: "Volver a #{label}", data: { scroll_restore: true }, class: "shrink-0 inline-flex items-center gap-1.5 h-9 pl-2 pr-2.5 sm:pr-3 rounded-control border border-line bg-surface text-ink-700 hover:bg-muted transition" do
        safe_join([
          icon("arrow-left", class: "w-4 h-4 shrink-0"),
          tag.span(label, class: "max-w-[180px] truncate text-label font-semibold")
        ])
      end
    end
  end

  # Volver a donde se vino (return_to), con el nombre de esa página: desde el organigrama dice «Organigrama»,
  # no «Compañías». Sin return_to, o si no se reconoce la página, quedan el destino y el nombre de siempre.
  def back_to_origin(label, fallback)
    url = safe_return_to(fallback)
    back_to(url == fallback ? label : (page_label_for(url) || label), url)
  end

  # El nombre de una página de la app por su dirección: la ficha o el registro que muestra (el nombre del
  # joven, de la compañía…), los del menú y las pocas que no están en él.
  def page_label_for(url)
    path = URI.parse(url).path.chomp("/")
    record_label = record_page_label(path)
    return record_label if record_label

    named = nav_items.filter_map { |item| [ URI.parse(item[:url]).path, item[:text] ] if item[:url] }
    extra = [ [ overview_companies_path, "Vista general" ], [ auxiliar_companies_path, "Compañías auxiliares" ],
              [ agenda_trainings_path, "Capacitaciones" ] ]
    # La dirección más larga que coincida gana: /companies/overview antes que /companies.
    (extra + named).sort_by { |route, _| -route.length }.find { |route, _| path == route || path.start_with?("#{route}/") }&.last
  rescue URI::InvalidURIError
    nil
  end

  RECORD_PAGES = {
    "participants" => ->(id) { Participant.find_by(id: id)&.first_name },
    "companies" => ->(id) { Company.find_by(id: id)&.name },
    "auxiliar_companies" => ->(id) { AuxiliarCompany.find_by(id: id)&.name },
    "logistics_areas" => ->(id) { LogisticsArea.find_by(id: id)&.name },
    "trainings" => ->(id) { Training.find_by(id: id)&.name },
    "inventories" => ->(id) { Inventory.find_by(id: id)&.name },
    "inventory_items" => ->(id) { InventoryItem.find_by(code: id)&.name },
    "expenses" => ->(id) { Expense.find_by(id: id)&.concept }
  }.freeze

  def record_page_label(path)
    route = Rails.application.routes.recognize_path(path)
    return "Asistencia nocturna" if route[:controller] == "night_attendances"
    return unless route[:action] == "show" && route[:id]

    RECORD_PAGES[route[:controller]]&.call(route[:id])
  rescue ActionController::RoutingError
    nil
  end

  # La ficha de un participante vuelve a donde se abrió: la lista de jóvenes o de staff, o el escáner
  # (registro o lector del panel), con return_to diciendo exactamente cuál.
  def participants_back
    if params[:from] == "escaner"
      back_to "Escáner", safe_return_to(checkins_path)
    elsif params[:from] == "staff" || (params[:from].blank? && participant_nav_section == "staff")
      back_to_origin "Staff", staff_participants_path
    else
      back_to_origin "Jóvenes", participants_path
    end
  end

  # "jovenes" o "staff" en las páginas de una ficha (/participants/:id/…), según el rol de esa persona; nil fuera de ellas.
  def participant_nav_section
    return @participant_nav_section if defined?(@participant_nav_section)

    id = request.path[%r{\A/participants/(\h{8}-\h{4}-\h{4}-\h{4}-\h{12})(/|\z)}, 1]
    rol = id && Participant.where(id: id).pick(:rol)
    @participant_nav_section = rol && (rol == "joven" ? "jovenes" : "staff")
  end

  # A dónde vuelve la página ({ label:, url: }), si es una de las que se abren desde otra (back_to).
  def page_back
    @page_back
  end

  def page_eyebrow
    content_for(:eyebrow).presence || Rails.configuration.x.event_name
  end

  def page_heading
    content_for(:heading).presence || content_for(:title).presence || "FSY Management"
  end

  # Pages that already render their own <h1> (dashboard hero, profile name) set :page_h1 so the top bar doesn't add a second one.
  def page_heading_tag
    content_for?(:page_h1) ? :p : :h1
  end
end
