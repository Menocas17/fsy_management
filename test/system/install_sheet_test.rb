require "application_system_test_case"

# La hoja de instalar la app sale sola en el navegador del teléfono: en iPhone con los pasos, en Android con el
# botón de verdad cuando Chrome da permiso, y desde Facebook o Instagram pide abrirla afuera. En la
# computadora no sale, y «Ahora no» la calla.
class InstallSheetTest < ApplicationSystemTestCase
  IPHONE_SAFARI_26 = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1".freeze
  IPHONE_CHROME = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/140.0.0.0 Mobile/15E148 Safari/604.1".freeze
  IPHONE_INSTAGRAM = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Instagram 390.0.0.0".freeze
  ANDROID_CHROME = "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36".freeze

  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
    cdp("Emulation.setUserAgentOverride", userAgent: "")
  end

  test "on an iPhone the steps slide one by one and don't come back in the same visit" do
    phone(IPHONE_SAFARI_26)
    visit new_session_path

    within_sheet do
      assert_text "Instala FSY en tu iPhone"
      click_on "Ver cómo"
      assert_text "Toca ⋯ y luego Compartir"
      assert_no_text "Es el cuadrito con una flecha"
      click_on "Siguiente"
      assert_text "Elige «Agregar a inicio»"
      click_on "Siguiente"
      assert_text "Deja encendido «Abrir como app web»"
      click_on "Listo, ya la agregué"
    end
    assert_no_selector "dialog.install-sheet[open]"

    visit new_session_path
    assert_no_selector "dialog.install-sheet[open]"
  end

  test "Chrome on an iPhone points to its own share button" do
    phone(IPHONE_CHROME)
    visit new_session_path

    within_sheet do
      click_on "Ver cómo"
      assert_text "En Chrome está arriba, a la derecha de la dirección"
    end
  end

  test "inside Instagram it asks to open the app in Safari" do
    phone(IPHONE_INSTAGRAM)
    visit new_session_path

    within_sheet do
      assert_text "Ábrela en tu navegador"
      assert_selector "a[href^='x-safari-https://']", text: "Abrir en Safari"
    end
  end

  test "on Android the install button uses the phone's own prompt, and «Ahora no» snoozes it" do
    phone(ANDROID_CHROME)
    visit new_session_path

    # Lo que haría Chrome al ver que la app se puede instalar.
    execute_script(<<~JS)
      const event = new Event('beforeinstallprompt', { cancelable: true });
      event.prompt = () => { window.prompted = true; };
      event.userChoice = Promise.resolve({ outcome: 'accepted' });
      window.dispatchEvent(event);
    JS

    within_sheet do
      assert_text "Instala FSY en tu teléfono"
      click_on "Instalar"
      assert_text "¡Listo!"
      click_on "Entendido"
    end
    assert evaluate_script("window.prompted")

    execute_script("sessionStorage.clear()")
    visit new_session_path
    execute_script("window.dispatchEvent(Object.assign(new Event('beforeinstallprompt'), { prompt() {}, userChoice: Promise.resolve({ outcome: 'dismissed' }) }))")
    within_sheet { click_on "Ahora no" }

    execute_script("sessionStorage.clear()")
    visit new_session_path
    execute_script("window.dispatchEvent(Object.assign(new Event('beforeinstallprompt'), { prompt() {}, userChoice: Promise.resolve({ outcome: 'dismissed' }) }))")
    assert_no_selector "dialog.install-sheet[open]", wait: 0.5
  end

  test "Configuración opens it on demand, and a computer never sees it on its own" do
    sign_in_as(users(:one))
    assert_no_selector "dialog.install-sheet[open]", wait: 0.5

    phone(IPHONE_SAFARI_26)
    execute_script("localStorage.setItem('fsy:install-snooze', String(Date.now() + 864e5))")
    visit settings_path
    assert_no_selector "dialog.install-sheet[open]", wait: 0.5

    click_on "Instalar en este teléfono"
    within_sheet { assert_text "Instala FSY en tu iPhone" }
  end

  test "the tutorial waits for the sheet, and doesn't start in the browser once the app was added" do
    Rails.configuration.x.tutorial_autostart = true
    counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    phone(IPHONE_SAFARI_26)
    visit new_session_path
    within_sheet { click_on "Ahora no" }
    sign_in_as(counselor, password: "Consejera1!")
    assert_text "Hola, María"

    execute_script("sessionStorage.clear(); localStorage.clear()")
    visit dashboard_path
    within_sheet do
      assert_no_text "Hola, María"
      click_on "Ya la tengo instalada"
    end
    assert_no_selector ".tour-coach", wait: 1
  ensure
    Rails.configuration.x.tutorial_autostart = false
  end

  private
    def phone(user_agent)
      cdp("Emulation.setUserAgentOverride", userAgent: user_agent)
      cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 2, mobile: true, screenWidth: 390, screenHeight: 844)
      cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
    end

    def within_sheet(&block)
      within("dialog.install-sheet[open]", &block)
    end

    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
