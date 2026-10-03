require "application_system_test_case"

# Lo propio del celular: la ficha a lo ancho de un teléfono y el jalar para recargar, con toques de verdad
# (Chrome DevTools Protocol), no con clics. SCREENSHOTS=dir guarda capturas para revisarlas a ojo.
class MobileTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @andrea = Participant.create!(first_name: "Andrea", last_name: "Chavarría Martínez", age: 14, stake: "puerto_cabezas",
                                  ward: "waspan", shirt_number: "m", gender: "M", rol: "consejero")
    User.create!(email_address: "andrea.chavarria.martinez@gmail.com", password: "Consejera1!", participant: @andrea)
  end

  test "the profile header stacks cleanly on a phone" do
    sign_in_as(@admin)
    emulate_phone
    visit participant_path(@andrea)

    within "[data-profile-actions]" do
      edit, qr, reset = [ find_link("Editar"), find("[data-profile-qr]"), find_button("Restablecer") ].map(&:rect)
      assert_operator edit.y, :<, qr.y, "Editar goes first, full width"
      assert_in_delta qr.y, reset.y, 1, "QR and reset share a row"
      assert_in_delta qr.height, reset.height, 1, "and neither wraps to two lines"
    end
    status = find("[data-account-status]")
    assert_text "Todavía no entra"
    assert_operator status.rect.x + status.rect.width, :<=, find("[data-profile-actions]").rect.then { |r| r.x + r.width } + 1

    save_screenshot(File.join(ENV["SCREENSHOTS"], "ficha-movil.png")) if ENV["SCREENSHOTS"]
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
