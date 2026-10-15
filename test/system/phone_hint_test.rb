require "application_system_test_case"

# Un teléfono que lo dice (Sec-CH-UA-Mobile: ?1, como Chrome en Android) recibe solo la versión de teléfono de
# las listas (DeviceHelper): que se vea y se use igual que antes, con sus filtros en la hoja.
class PhoneHintTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    Participant.create!(first_name: "Andrea", last_name: "Chavarría Martínez", age: 24, stake: "puerto_cabezas",
                        ward: "bilwi", shirt_number: "m", gender: "M", rol: "consejero")
  end

  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
    cdp("Emulation.setUserAgentOverride", userAgent: "")
  end

  test "an Android phone gets only the staff cards and filters them from the sheet" do
    sign_in_as(@admin)
    cdp("Emulation.setDeviceMetricsOverride", width: 412, height: 892, deviceScaleFactor: 2, mobile: true)
    cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
    cdp("Emulation.setUserAgentOverride",
        userAgent: "Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0 Mobile Safari/537.36",
        userAgentMetadata: { platform: "Android", platformVersion: "14", architecture: "", model: "Pixel 7", mobile: true })
    # Con el user agent de Android sale sola la hoja de instalar: se pospone, como con «Ahora no».
    execute_script("localStorage.setItem('fsy:install-snooze', String(Date.now() + 86400000))")
    visit staff_participants_path

    assert_no_selector "table", visible: :all
    assert_selector "a", text: "Andrea Chavarría Martínez"
    assert_equal evaluate_script("window.innerWidth"), evaluate_script("document.documentElement.scrollWidth"), "la página no se desliza de lado"

    find("[data-filter-sheet-trigger]").click
    find("select[aria-label='Filtrar por rol']").select("Consejero")
    click_button "Ver resultados"
    assert_no_selector "select[aria-label='Filtrar por rol']", visible: true
    assert_selector "[data-active-filter='rol']", visible: :all
    assert_text "Andrea Chavarría Martínez"
    assert_no_selector "table", visible: :all
  end

  private
    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
