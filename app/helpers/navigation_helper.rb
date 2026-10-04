module NavigationHelper
  # El menú lateral y el cajón del teléfono comparten esta estructura: «Inicio» suelto y luego grupos
  # desplegables (shared/_nav_sections + nav_groups_controller). Cada grupo tiene un id estable: con él se
  # recuerda en el dispositivo si la persona lo dejó abierto o cerrado.
  def nav_sections
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
        (if Current.user&.inventory_member?
           { text: "Inventario", url: inventories_path, lucide_icon: "boxes",
             # Las fichas de artículo cuelgan de /articulos, fuera de /inventario.
             active_paths: [ inventories_path, "/articulos" ] }
         else
           { text: "Inventario", lucide_icon: "boxes", disabled: true, hint: "Solo para el comité de logística" }
         end),
        (if Current.user&.finance_viewer?
           { text: "Finanzas", url: finances_path, lucide_icon: "wallet", active_paths: [ finances_path ] }
         else
           { text: "Finanzas", lucide_icon: "wallet", disabled: true, hint: "Solo para el área de Finanzas, logística y la dirección" }
         end),
        { text: "Librería", lucide_icon: "library", disabled: true }
      ] },
      { id: "seguimiento", label: "Seguimiento", items: [
        (if Current.user&.reports_viewer?
           { text: "Reportes", url: reports_path, lucide_icon: "file-text",
             active_paths: [ reports_path, participant_imports_path ] }
         else
           { text: "Reportes", lucide_icon: "file-text", disabled: true, hint: "Solo para dirección y el director de logística" }
         end),
        night_attendance_nav_item,
        ({ text: "Historial", url: audit_logs_path, lucide_icon: "clipboard-clock" } if Current.user&.admin_or_staff_manager?)
      ] }
    ]
    # "Mi perfil" lives in the account menu of the top bar; a section with no items is dropped.
    sections.filter_map do |section|
      items = section[:items].compact.map { |item| item.merge(is_nav: true) }
      section.merge(items: items, active: items.any? { |item| nav_item_active?(**item) }) if items.any?
    end
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
    extra = [ [ overview_companies_path, "Vista general" ], [ auxiliar_companies_path, "Compañías auxiliares" ] ]
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
    elsif params[:from] == "staff"
      back_to_origin "Staff", staff_participants_path
    else
      back_to_origin "Jóvenes", participants_path
    end
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
