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
        { text: "Logística", lucide_icon: "truck", disabled: true },
        { text: "Reportes", lucide_icon: "file-text", disabled: true },
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
