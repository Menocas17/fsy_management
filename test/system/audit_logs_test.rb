require "application_system_test_case"

# El historial en el teléfono: tarjetas a lo ancho y filtros que se deslizan dentro de su fila, nunca la
# página entera de lado. SCREENSHOTS=dir guarda capturas.
class AuditLogsTest < ApplicationSystemTestCase
  setup do
    juan = participants(:juan)
    AuditLog.create!(actor_name: "Ana Pérez", action: "voided", category: :registro, target_type: "Participant", target_id: juan.id,
                     summary: "Anuló la llegada de Juan Pérez (Llegó con el gafete de otra persona: se lo prestó su hermano)",
                     target_name: "Juan Pérez")
    AuditLog.create!(actor_name: "Rodolfo Menocal Castillo", action: "updated", category: :participantes, target_type: "Participant",
                     target_id: juan.id, summary: "Actualizó teléfono y alergias de Juan Pérez", target_name: "Juan Pérez")
  end

  teardown do
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
  end

  test "on a phone the history fits the screen and the filters open in a sheet from the Filtros button" do
    sign_in_as(users(:one))
    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 2, mobile: true)
    visit audit_logs_path

    assert_selector "[data-audit-log-card]", count: 2
    assert_equal evaluate_script("window.innerWidth"), evaluate_script("document.documentElement.scrollWidth"), "la página no se desliza de lado"
    assert_no_selector "select[aria-label='Filtrar por acción']", visible: true
    save_screenshot(File.join(ENV["SCREENSHOTS"], "historial-movil.png")) if ENV["SCREENSHOTS"]

    find("[data-filter-sheet-trigger]").click
    find("[data-audit-filters] select[aria-label='Filtrar por acción']").select("Anuló")
    assert_selector "[data-audit-log-card]", count: 1, visible: :all
    within("[data-filter-sheet-trigger]") { assert_text "1" }
    save_screenshot(File.join(ENV["SCREENSHOTS"], "historial-movil-filtros.png")) if ENV["SCREENSHOTS"]
    click_button "Ver resultados"
    assert_no_selector "select[aria-label='Filtrar por acción']", visible: true
    assert_text "Anuló la llegada de Juan Pérez"
    assert_selector "a[data-audit-clear]"
  end

  test "on a desktop the filters sit in one row next to the search" do
    page.driver.browser.manage.window.resize_to(1400, 900)
    sign_in_as(users(:one))
    visit audit_logs_path

    tops = all("[data-audit-filters] select").map { |select| select.rect.y.round }
    assert_equal 1, tops.uniq.size
    fill_in "Buscar por persona, registro o acción", with: "telefono"
    assert_selector "[data-audit-log-id]", count: 1
    save_screenshot(File.join(ENV["SCREENSHOTS"], "historial-escritorio.png")) if ENV["SCREENSHOTS"]
  end
end
