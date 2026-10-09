require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @training = Training.create!(name: "Diciembre", held_on: 2.months.from_now.to_date)
  end

  test "activating a registration closes the one that was open" do
    sign_in_as(users(:one))
    patch scan_windows_settings_path, params: { scan: "arrival" }

    get settings_path
    assert_select "[data-scan-window='arrival'] [role='switch'][aria-checked='true']"
    assert_select "[data-scan-window='training:#{@training.id}'] [role='switch'][aria-checked='false']"

    patch scan_windows_settings_path, params: { scan: "training:#{@training.id}" }

    assert_redirected_to settings_path(anchor: "settings-scan")
    assert @training.scan_window.open?
    assert_not ScanWindow.arrival.open?
  end

  test "turning off the active one closes the scanner, and an unknown one too" do
    sign_in_as(users(:one))
    ScanWindow.activate!(ScanWindow.arrival)

    patch scan_windows_settings_path, params: { scan: "" }
    assert_nil ScanWindow.active

    patch scan_windows_settings_path, params: { scan: "training:nope" }
    assert_nil ScanWindow.active
  end

  test "the logistics director activates registrations too" do
    director = Participant.create!(first_name: "Luis", last_name: "Mena", age: 40, stake: "las_americas",
                                   shirt_number: "m", gender: "H", rol: :director_logistica)
    sign_in_as(User.create!(email_address: "luis@fsy.com", password: "Logistica1!", participant: director))

    get settings_path
    assert_select "#settings-scan"

    patch scan_windows_settings_path, params: { scan: "arrival" }
    assert ScanWindow.arrival.open?
  end

  test "the directors, with full access, change them too" do
    director = Participant.create!(first_name: "Ana", last_name: "Ruiz", age: 40, stake: "las_americas",
                                   shirt_number: "m", gender: "M", rol: :director)
    sign_in_as(User.create!(email_address: "ana@fsy.com", password: "Directora1!", participant: director))

    get settings_path
    assert_select "#settings-scan"

    patch scan_windows_settings_path, params: { scan: "arrival" }
    assert ScanWindow.arrival.open?
  end

  test "nobody else sees or changes them" do
    counselor = Participant.create!(first_name: "Ana", last_name: "Ruiz", age: 30, stake: "las_americas",
                                    shirt_number: "m", gender: "M", rol: :consejero)
    sign_in_as(User.create!(email_address: "ana@fsy.com", password: "Consejera1!", participant: counselor))

    get settings_path
    assert_select "#settings-scan", 0

    patch scan_windows_settings_path, params: { scan: "arrival" }
    assert_nil ScanWindow.active
  end
end
