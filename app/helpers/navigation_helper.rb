module NavigationHelper
  # Sidebar and mobile drawer share this structure: an unlabeled "Inicio" group, then one group per category.
  def nav_sections
    sections = [
      { label: nil, items: [
        { text: "Inicio", url: dashboard_path, lucide_icon: "house" }
      ] },
      { label: "Participantes", items: [
        { text: "Jóvenes", url: participants_path, lucide_icon: "users", section: "jovenes",
          active_paths: [ participants_path ], except_paths: [ staff_participants_path, myprofile_participants_path ] },
        { text: "Staff", url: staff_participants_path, lucide_icon: "user-check", section: "staff",
          active_paths: [ staff_participants_path ] }
      ] },
      { label: "Gestión", items: [
        { text: "Compañías", url: companies_path, lucide_icon: "building-2", section: "companies", active_paths: [ companies_path, auxiliar_companies_path ] },
        { text: "Organigrama", url: organigrama_path, lucide_icon: "network" },
        { text: "Agenda", url: agenda_path, lucide_icon: "calendar-days", active_paths: [ agenda_path, activities_path ] },
        { text: "Librería", lucide_icon: "library", disabled: true },
        (if Current.user&.inventory_member?
           { text: "Inventario", url: inventories_path, lucide_icon: "boxes",
             # Las fichas de artículo cuelgan de /articulos, fuera de /inventario.
             active_paths: [ inventories_path, "/articulos" ] }
         else
           { text: "Inventario", lucide_icon: "boxes", disabled: true }
         end),
        (if Current.user&.reports_viewer?
           { text: "Reportes", url: reports_path, lucide_icon: "file-text",
             active_paths: [ reports_path, new_participant_import_path ] }
         else
           { text: "Reportes", lucide_icon: "file-text", disabled: true }
         end),
        { text: "Finanzas", lucide_icon: "wallet", disabled: true },
        ({ text: "Alertas", url: alerts_path, lucide_icon: "megaphone", active_paths: [ alerts_path ] } if Current.user&.alert_manager?),
        ({ text: "Historial", url: audit_logs_path, lucide_icon: "clipboard-clock" } if Current.user&.admin_or_staff_manager?)
      ] }
    ]
    # "Mi perfil" lives in the account menu of the top bar; a section with no items is dropped.
    sections.filter_map do |section|
      items = section[:items].compact.map { |item| item.merge(is_nav: true) }
      section.merge(items: items) if items.any?
    end
  end

  def nav_items
    nav_sections.flat_map { |section| section[:items] }
  end

  # Cada vista de detalle dice a dónde vuelve y la barra superior lo pinta siempre en el mismo lugar,
  # así nadie depende de las flechas del navegador.
  def back_to(label, url)
    content_for :back do
      link_to url, title: "Volver a #{label}", class: "shrink-0 inline-flex items-center gap-1.5 h-9 pl-2 pr-2.5 sm:pr-3 rounded-[11px] border border-line dark:border-slate-600 bg-surface dark:bg-slate-800 text-ink-700 dark:text-slate-300 hover:bg-canvas dark:hover:bg-slate-700 transition" do
        safe_join([
          icon("arrow-left", class: "w-4 h-4 shrink-0"),
          tag.span(label, class: "max-w-[180px] truncate text-[12.5px] font-semibold")
        ])
      end
    end
  end

  # La ficha de un participante vuelve a la lista de la que vino.
  def participants_back
    if params[:from] == "staff"
      back_to "Staff", safe_return_to(staff_participants_path)
    else
      back_to "Jóvenes", safe_return_to(participants_path)
    end
  end

  def page_eyebrow
    content_for(:eyebrow).presence || "FSY 2026"
  end

  def page_heading
    content_for(:heading).presence || content_for(:title).presence || "FSY Management"
  end

  # Pages that already render their own <h1> (dashboard hero, profile name) set :page_h1 so the top bar doesn't add a second one.
  def page_heading_tag
    content_for?(:page_h1) ? :p : :h1
  end
end
