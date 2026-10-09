require "application_system_test_case"

# Sin elección guardada, el teléfono arranca en oscuro y la computadora en claro; lo que se elige en
# Configuración gana en los dos.
class ThemeOnPhoneTest < ApplicationSystemTestCase
  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
  end

  test "a phone opens in dark mode unless light was chosen, a computer stays light" do
    sign_in_as(users(:one))
    assert_not dark?, "en la computadora, claro"

    cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 2, mobile: true, screenWidth: 390, screenHeight: 844)
    cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
    visit settings_path
    assert dark?, "en el teléfono, oscuro por defecto"
    assert find("#theme-toggle", visible: :all).checked?, "el interruptor dice lo que se ve"

    find("label[for='theme-toggle']").click
    assert_not dark?
    visit dashboard_path
    assert_not dark?, "la elección de claro queda guardada"
  end

  private
    def dark?
      evaluate_script("document.documentElement.classList.contains('dark')")
    end

    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
