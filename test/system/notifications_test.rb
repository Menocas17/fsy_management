require "application_system_test_case"

# Las alertas se tocan para abrirlas y cada quien las quita de su lista: con la X en escritorio y
# deslizándolas a la izquierda en el teléfono (toques de verdad por CDP). SCREENSHOTS=dir guarda capturas.
class NotificationsTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @first = Alert.create!(title: "Bienvenida", body: "Nos vemos en el auditorio.", sender_name: "Marta", audience: :todos, created_at: 2.minutes.ago)
    @second = Alert.create!(title: "Gasto aprobado", body: "Revisa finanzas.", sender_name: "Finanzas", audience: :todos, link_path: "/finanzas", created_at: 1.minute.ago)
  end

  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
  end

  test "on a desktop the bell's alerts open, and the X or Limpiar todo take them away" do
    page.driver.browser.manage.window.resize_to(1400, 1000)
    sign_in_as(@admin)

    find("[data-notifications-trigger]").click
    within("[data-dropdown-target=menu]") do
      find("[data-alert-id='#{@first.id}']").hover
      save_screenshot(File.join(ENV["SCREENSHOTS"], "campanita-x.png")) if ENV["SCREENSHOTS"]
      find("[data-alert-id='#{@first.id}'] [data-alert-dismiss]").click
      assert_no_selector "[data-alert-id='#{@first.id}']"
      assert_selector "[data-alert-id='#{@second.id}']", text: "Gasto aprobado"
    end
    assert_selector "[data-dropdown-target=menu]", visible: true # el menú sigue abierto

    within("[data-dropdown-target=menu]") { click_on "Limpiar todo" }
    within("dialog[open]") { click_on "Sí, limpiar" } # el clic en el diálogo cierra el menú
    assert_selector "[data-notifications-trigger] [data-unread-count]", visible: :hidden
    find("[data-notifications-trigger]").click
    within("[data-dropdown-target=menu]") { assert_selector "[data-empty-state='notifications']" }
    assert_equal 2, Alert.count, "solo se quitaron de la lista de esta persona"
  end

  test "tapping an alert opens what it announces" do
    sign_in_as(@admin)
    visit notifications_path

    find("main [data-alert-id='#{@first.id}']").click # en cualquier parte de la tarjeta, no solo el título
    assert_current_path alert_path(@first)
  end

  test "on a phone an alert swipes left to show Eliminar, and a long swipe deletes it" do
    sign_in_as(@admin)
    emulate_phone
    visit notifications_path

    assert_no_selector "main [data-alert-dismiss]" # sin hover no hay X: se desliza
    swipe(@second, by: 110, screenshot: "deslizando.png")
    assert_selector "main [data-alert-swipe-delete]", visible: true
    save_screenshot(File.join(ENV["SCREENSHOTS"], "eliminar-visible.png")) if ENV["SCREENSHOTS"]

    find("main [data-alert-id='#{@second.id}']").click # tocarla abierta la cierra, no la abre
    assert_current_path notifications_path
    assert_no_selector "main [data-alert-swipe-delete]", visible: true

    swipe(@second, by: 110)
    find("main [data-alert-swipe-delete]").click
    assert_no_selector "main [data-alert-id='#{@second.id}']"

    swipe(@first, by: 330)
    assert_no_selector "main [data-alert-id='#{@first.id}']"
    assert_selector "main [data-empty-state='notifications']"
    assert_equal 2, @admin.alert_dismissals.count
  end

  private
    def emulate_phone
      cdp("Emulation.setDeviceMetricsOverride", width: 412, height: 892, deviceScaleFactor: 2, mobile: true)
      cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
    end

    def swipe(alert, by:, screenshot: nil)
      rect = find("main [data-alert-id='#{alert.id}']").rect
      x = rect.x + rect.width - 30
      y = rect.y + rect.height / 2
      cdp("Input.dispatchTouchEvent", type: "touchStart", touchPoints: [ { x: x, y: y } ])
      (1..12).each do |step|
        cdp("Input.dispatchTouchEvent", type: "touchMove", touchPoints: [ { x: x - by * step / 12, y: y } ])
      end
      save_screenshot(File.join(ENV["SCREENSHOTS"], screenshot)) if screenshot && ENV["SCREENSHOTS"]
      cdp("Input.dispatchTouchEvent", type: "touchEnd", touchPoints: [])
    end

    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
