require "application_system_test_case"

# Las hojas que suben desde abajo en el teléfono (la de «Más» del modo simple y la de filtros): se cierran
# arrastrándolas hacia abajo, y la de «Más» no reaparece arriba al volver a una página que se dejó con ella abierta.
class SheetsOnPhoneTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @admin.update!(simple_mode: true)
  end

  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
  end

  test "the Más sheet closes when dragged down, and comes back closed after leaving through it" do
    sign_in_as(@admin)
    emulate_phone(390)
    visit agenda_path

    open_more
    sheet = find("dialog[data-dialog-name='mas'] [data-controller='sheet-drag']")
    drag(from: sheet.rect.y + 20, by: 260)
    assert_no_selector "dialog[data-dialog-name='mas'][open]", visible: :all

    # Una arrastrada corta y lenta no la cierra: vuelve a su lugar.
    open_more
    drag(from: sheet.rect.y + 20, by: 30, steps: 30)
    assert_selector "dialog[data-dialog-name='mas'][open]"

    # Salir por uno de sus enlaces deja la copia de esta página con la hoja abierta; al volver, Turbo pinta esa
    # copia y la hoja no debe aparecer (antes se veía un instante arriba de todo).
    within("[data-more-items]") { click_on "Alertas" }
    assert_current_path alerts_path
    go_back
    assert_current_path agenda_path
    assert_no_selector "dialog[open]", visible: :all
  end

  test "the filter sheet closes when dragged down" do
    sign_in_as(@admin)
    emulate_phone(390)
    visit staff_participants_path

    find("[data-filter-sheet-trigger]").click
    sheet = find("[data-filter-sheet-target='sheet'][data-open]")
    sleep 0.4 # termina de subir
    drag(from: sheet.rect.y + 12, by: 300)
    assert_no_selector "[data-filter-sheet-target='sheet'][data-open]", visible: :all
    assert_equal "false", find("[data-filter-sheet-trigger]")["aria-expanded"]
  end

  test "on a 320 px phone the trainings actions share one row" do
    ScanWindow.activate!(ScanWindow.for(Training.create!(name: "Primera", held_on: Date.current)))
    sign_in_as(@admin)
    emulate_phone(320)
    visit agenda_trainings_path

    within("[data-training-actions]") do
      new_training = find_link("Nueva capacitación")
      assert_equal "Nueva", new_training.text
      assert_no_link "PDF de asistencia"
    end
    rects = all("[data-training-actions] > a").map(&:rect)
    assert_equal 2, rects.size, "escanear y crear"
    assert_equal 1, rects.map(&:y).uniq.size, "los botones van en una sola fila"
    assert_equal evaluate_script("window.innerWidth"), evaluate_script("document.documentElement.scrollWidth")
  end

  private
    def emulate_phone(width)
      cdp("Emulation.setDeviceMetricsOverride", width: width, height: 844, deviceScaleFactor: 2, mobile: true)
      cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
    end

    def open_more
      find("[data-bottom-nav-item='Más']").click
      assert_selector "dialog[data-dialog-name='mas'][open]"
      sleep 0.2
    end

    def drag(from:, by:, steps: 10, x: 195)
      cdp("Input.dispatchTouchEvent", type: "touchStart", touchPoints: [ { x: x, y: from } ])
      (1..steps).each do |step|
        cdp("Input.dispatchTouchEvent", type: "touchMove", touchPoints: [ { x: x, y: from + by * step / steps } ])
      end
      cdp("Input.dispatchTouchEvent", type: "touchEnd", touchPoints: [])
    end

    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
