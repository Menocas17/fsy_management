require "test_helper"

class NavigationHelperTest < ActionView::TestCase
  test "lists the sections in sidebar order" do
    assert_equal [ "Inicio", "Jóvenes", "Staff", "Compañías", "Organigrama", "Agenda", "Librería", "Logística", "Reportes", "Finanzas" ],
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

    assert_equal [ "Librería", "Logística", "Reportes", "Finanzas" ], disabled.map { |item| item[:text] }
    assert disabled.all? { |item| item[:url].nil? }
  end

  test "groups items under the sidebar categories" do
    assert_equal [ nil, "Participantes", "Gestión" ], nav_sections.map { |section| section[:label] },
                 "Mi perfil moved to the account menu, so the Cuenta section is gone"
    assert_equal [ "Compañías", "Organigrama", "Agenda", "Librería", "Logística", "Reportes", "Finanzas" ],
                 nav_sections.third[:items].map { |item| item[:text] }
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
end
