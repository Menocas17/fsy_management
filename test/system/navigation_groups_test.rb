require "application_system_test_case"

# Los grupos del menú lateral se cierran y se quedan cerrados de página en página; el de la página abierta
# siempre se ve.
class NavigationGroupsTest < ApplicationSystemTestCase
  setup do
    page.driver.browser.manage.window.resize_to(1400, 1000)
    LogisticsArea.create!(name: "Registro", description: "Recibe a los jóvenes", checkin: true)
    LogisticsArea.create!(name: "Finanzas", finance: true)
  end

  test "a closed group stays closed across pages, except when the page is inside it" do
    sign_in_as(users(:one))

    within("aside") do
      within("[data-nav-group='participantes']") { click_on "Participantes" }
      assert_no_link "Jóvenes"
      within("[data-nav-group='seguimiento']") { click_on "Seguimiento" }
      click_on "Áreas"
    end

    assert_current_path logistics_areas_path
    within("aside") do
      assert_no_link "Jóvenes" # sigue cerrado después de navegar
      assert_selector "[data-nav-group='participantes'][data-open='false']", text: "4"
      assert_link "Áreas"
    end
    save_screenshot(File.join(ENV["SCREENSHOTS"], "areas-escritorio.png")) if ENV["SCREENSHOTS"]

    click_on "Administrar", match: :first
    save_screenshot(File.join(ENV["SCREENSHOTS"], "area-detalle.png")) if ENV["SCREENSHOTS"]

    visit participants_path
    within("aside") { assert_link "Jóvenes" } # su grupo se abre porque la página está adentro
  end

  test "the phone drawer keeps its look, with the same groups" do
    # Con el modo simple (encendido por defecto) el teléfono lleva la barra inferior en vez del cajón.
    users(:one).update!(simple_mode: false)
    sign_in_as(users(:one))
    resize_to_mobile
    visit logistics_areas_path

    click_on "Abrir menú"
    within("#mobile-menu") do
      assert_selector "[data-nav-group='logistica'][data-open='true']"
      click_on "Evento"
      assert_no_link "Agenda"
    end
    save_screenshot(File.join(ENV["SCREENSHOTS"], "cajon-telefono.png")) if ENV["SCREENSHOTS"]
  end
end
