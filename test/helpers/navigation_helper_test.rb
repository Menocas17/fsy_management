require "test_helper"

class NavigationHelperTest < ActionView::TestCase
  test "lists the sections in sidebar order" do
    assert_equal [ "Inicio", "Jóvenes", "Staff", "Compañías", "Organigrama", "Agenda", "Inventario", "Finanzas", "Librería", "Reportes" ],
                 nav_items.map { |item| item[:text] }
  end

  test "shows Historial and Alertas only to staff managers" do
    Current.session = users(:one).sessions.create!

    assert_includes nav_items.map { |item| item[:text] }, "Historial"
    assert_includes nav_items.map { |item| item[:text] }, "Alertas"
  ensure
    Current.reset
  end

  test "enabled items point at a real route" do
    nav_items.reject { |item| item[:disabled] }.each do |item|
      assert item[:is_nav], "#{item[:text]} should be a nav item"
      assert item[:url].start_with?("/"), "#{item[:text]} should point at an app route"
    end
  end

  test "not-yet-built sections are disabled and have no destination" do
    disabled = nav_items.select { |item| item[:disabled] }

    assert_equal [ "Inventario", "Finanzas", "Librería", "Reportes" ], disabled.map { |item| item[:text] }
    assert disabled.all? { |item| item[:url].nil? }
  end

  test "groups items under the sidebar categories" do
    Current.session = users(:one).sessions.create!

    groups = nav_sections.to_h { |section| [ section[:label], section[:items].map { |item| item[:text] } ] }
    assert_equal({ nil => [ "Inicio" ],
                   "Participantes" => [ "Jóvenes", "Staff", "Compañías", "Organigrama" ],
                   "Evento" => [ "Agenda", "Registro", "Alertas" ],
                   "Logística" => [ "Áreas", "Inventario", "Finanzas", "Librería" ],
                   "Seguimiento" => [ "Reportes", "Historial" ] }, groups)
  ensure
    Current.reset
  end

  test "a group starts open unless the person closed it, and the open page's group is always open" do
    participantes = { id: "participantes", active: false }
    assert nav_group_open?(participantes)

    cookies[:fsy_nav_closed] = "participantes.seguimiento"
    assert_not nav_group_open?(participantes)
    assert nav_group_open?(participantes.merge(active: true))
    assert nav_group_open?({ id: "evento", active: false })
  end

  test "every nav item uses a Lucide icon" do
    assert nav_items.all? { |item| item[:lucide_icon].present? }
  end

  test "top bar shows the page eyebrow and title" do
    assert_equal "FSY 2026", page_eyebrow

    content_for :title, "Jóvenes"
    content_for :eyebrow, "Participantes"
    assert_equal "Participantes", page_eyebrow
    assert_equal "Jóvenes", page_heading
    assert_equal :h1, page_heading_tag

    content_for :page_h1, "true"
    assert_equal :p, page_heading_tag
  end

  test "items can be splatted straight into ButtonComponent" do
    nav_items.each { |item| assert ButtonComponent.new(**item) }
  end

  test "the way back is named after the page it returns to" do
    assert_equal "Organigrama", page_label_for("/organigrama?scope=logistica")
    assert_equal "Vista general", page_label_for(overview_companies_path)
    assert_equal "Compañías", page_label_for(companies_path)
    assert_equal "Jóvenes", page_label_for("#{participants_path}?stake=villa_flor")
    assert_nil page_label_for("/no-existe")
  end
end
