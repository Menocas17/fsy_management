require "application_system_test_case"

# Lo propio del celular: la ficha a lo ancho de un teléfono y el jalar para recargar, con toques de verdad
# (Chrome DevTools Protocol), no con clics. SCREENSHOTS=dir guarda capturas para revisarlas a ojo.
class MobileTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @andrea = Participant.create!(first_name: "Andrea", last_name: "Chavarría Martínez", age: 14, stake: "puerto_cabezas",
                                  ward: "bilwi", shirt_number: "m", gender: "M", rol: "consejero")
    User.create!(email_address: "andrea.chavarria.martinez@gmail.com", password: "Consejera1!", participant: @andrea)
  end

  # La emulación del teléfono vive en el navegador, que se reusa entre pruebas: sin esto, la siguiente
  # prueba de sistema correría también como celular.
  teardown do
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
  end

  test "the profile header stacks cleanly on a phone" do
    # El volver de la barra reemplaza al botón del cajón, que solo existe con el modo simple apagado.
    @admin.update!(simple_mode: false)
    sign_in_as(@admin)
    emulate_phone
    visit participant_path(@andrea)

    within "[data-profile-actions]" do
      qr, edit = [ find("[data-profile-qr]"), find_link("Editar") ].map(&:rect)
      assert_in_delta qr.y, edit.y, 1, "QR and Editar share a row"
      assert_in_delta qr.width, edit.width, 1, "evenly"
      assert_no_button "Restablecer contraseña"
    end
    assert_photo_over_the_banner
    # El correo vive en Contacto, no bajo el nombre.
    within("[data-profile-actions]") { assert_no_text "andrea.chavarria.martinez@gmail.com" }
    assert_no_selector "[data-account-status]"
    within("[data-contact-account]") { assert_text "Todavía no entra" }

    # Como en iPhone: la barra cambia el menú por «‹ Staff» (Andrea es consejera), y no hay otro volver sobre el contenido.
    assert_no_selector "[data-mobile-menu-target='trigger']", visible: true
    assert_selector "a[data-page-back-mobile]", text: "Staff", count: 1
    assert_no_selector "[data-page-back] a", visible: true

    save_screenshot(File.join(ENV["SCREENSHOTS"], "ficha-movil.png")) if ENV["SCREENSHOTS"]
    # Toda la zona del título vuelve, no solo la flecha: lo que hay bajo el centro del título es el enlace.
    under_title = evaluate_script(<<~JS)
      (() => {
        const title = [...document.querySelectorAll("[data-page-header] p")].find((p) => p.textContent.includes("Perfil del participante"));
        const box = title.getBoundingClientRect();
        return document.elementFromPoint(box.x + box.width / 2, box.y + box.height / 2).closest("a")?.dataset.pageBackMobile;
      })()
    JS
    assert_equal "true", under_title
    find("a[data-page-back-mobile]").click
    assert_current_path staff_participants_path
    assert_selector "[data-mobile-menu-target='trigger']", visible: true
  end

  test "on a phone the list filters open in a sheet that counts what is applied" do
    sign_in_as(@admin)
    emulate_phone
    visit staff_participants_path

    assert_no_selector "select[aria-label='Filtrar por rol']", visible: true
    assert_equal evaluate_script("window.innerWidth"), evaluate_script("document.documentElement.scrollWidth"), "la página no se desliza de lado"
    save_screenshot(File.join(ENV["SCREENSHOTS"], "staff-movil.png")) if ENV["SCREENSHOTS"]

    find("[data-filter-sheet-trigger]").click
    find("select[aria-label='Filtrar por rol']").select("Consejero")
    assert_selector "[data-active-filter='rol']", visible: :all
    within("[data-filter-sheet-trigger]") { assert_text "1" }
    save_screenshot(File.join(ENV["SCREENSHOTS"], "staff-movil-filtros.png")) if ENV["SCREENSHOTS"]

    click_button "Ver resultados"
    assert_no_selector "select[aria-label='Filtrar por rol']", visible: true
    assert_text "Andrea Chavarría Martínez"

    # Limpiar vuelve a la lista sin que la copia guardada (con la hoja abierta) se asome.
    click_link "Limpiar todo"
    assert_no_selector "[data-active-filters]"
    assert_no_selector "[data-filter-sheet-target][data-open]", visible: :all
    within("[data-filter-sheet-trigger]") { assert_no_selector "[data-filter-sheet-target='count']" }
  end

  test "on a wide screen the profile buttons stay in one row" do
    page.driver.browser.manage.window.resize_to(1400, 1000) # otras pruebas dejan la ventana angosta
    sign_in_as(@admin)
    visit participant_path(@andrea)

    within "[data-profile-actions]" do
      tops = [ find("[data-profile-qr]"), find_link("Editar") ].map { |b| b.rect.y }
      assert_equal 1, tops.map(&:round).uniq.size, "QR and edit side by side"
    end
    within("[data-contact-account]") do
      reset = find_button("Restablecer contraseña").rect
      strip = find(:xpath, ".").rect
      assert_operator reset.x + reset.width, :<=, strip.x + strip.width, "the button stays inside the card"
    end
    save_screenshot(File.join(ENV["SCREENSHOTS"], "ficha-escritorio.png")) if ENV["SCREENSHOTS"]
    assert_photo_over_the_banner
  end

  test "creating an account offers the ficha's email or another one" do
    @andrea.user.destroy
    @andrea.update!(email_address: "andrea@gmail.com")
    sign_in_as(@admin)
    visit participant_path(@andrea)

    click_on "Crear cuenta"
    within "dialog[data-dialog-name='account']" do
      assert_text "andrea@gmail.com"
      assert_no_field "Correo electrónico"
      choose "Usar otro correo"
      fill_in "Correo electrónico", with: "andrea.nueva@gmail.com"
      fill_in "Confirmar el correo", with: "andrea.nueva@gmail.com"
      save_screenshot(File.join(ENV["SCREENSHOTS"], "dialogo-cuenta.png")) if ENV["SCREENSHOTS"]
      click_on "Crear cuenta"
    end

    assert_text "Se creó la cuenta"
    within("[data-contact-email]") { assert_text "andrea.nueva@gmail.com" }
  end

  test "pulling down from the top reloads the page" do
    sign_in_as(@admin)
    emulate_phone
    visit participant_path(@andrea)
    page.execute_script("document.body.dataset.beforeReload = '1'")

    pull(from: 300, by: 60)
    assert_selector "body[data-before-reload]" # un jalón corto no recarga
    assert_equal "idle", find("[data-pull-refresh-target=indicator]", visible: :all)["data-state"]

    pull(from: 300, by: 260, screenshot: "jalando.png")
    assert_no_selector "body[data-before-reload]", wait: 5
    assert_current_path participant_path(@andrea)
  end

  private
    # La foto sobresale de la tarjeta blanca hacia el banner, en vez de hundirse en ella.
    def assert_photo_over_the_banner
      photo = find("[data-profile-photo]").rect
      card = find("[data-profile-photo]").find(:xpath, "ancestor::div[contains(@class, '-mt-[58px]')]").rect
      assert_operator photo.y, :<, card.y - 10, "the photo rises above the card"
    end

    def emulate_phone
      cdp("Emulation.setDeviceMetricsOverride", width: 412, height: 892, deviceScaleFactor: 2, mobile: true)
      cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
    end

    def pull(from:, by:, screenshot: nil)
      cdp("Input.dispatchTouchEvent", type: "touchStart", touchPoints: [ { x: 200, y: from } ])
      (1..12).each do |step|
        cdp("Input.dispatchTouchEvent", type: "touchMove", touchPoints: [ { x: 200, y: from + by * step / 12 } ])
      end
      save_screenshot(File.join(ENV["SCREENSHOTS"], screenshot)) if screenshot && ENV["SCREENSHOTS"]
      cdp("Input.dispatchTouchEvent", type: "touchEnd", touchPoints: [])
    end

    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
