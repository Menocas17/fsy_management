require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @training = Training.create!(name: "Diciembre", held_on: 2.months.from_now.to_date)
  end

  test "the system admin opens or closes each registration by hand" do
    sign_in_as(users(:one))

    get settings_path
    assert_select "[data-scan-window='arrival'] select"
    assert_select "[data-scan-window='trainings[#{@training.id}]'] select"

    patch scan_windows_settings_path, params: { arrival: "closed", trainings: { @training.id => "open" } }

    assert_redirected_to settings_path(anchor: "settings-scan")
    assert_equal "closed", ScanWindow.arrival.mode
    assert @training.reload.scan_open?
    assert @training.scan_window.open?
  end

  test "an unknown mode is ignored instead of saved" do
    sign_in_as(users(:one))

    patch scan_windows_settings_path, params: { arrival: "whenever", trainings: { @training.id => "sometimes" } }

    assert_equal "auto", ScanWindow.arrival.mode
    assert @training.reload.scan_auto?
  end

  test "nobody else sees or changes the scan windows, not even the directors" do
    director = Participant.create!(first_name: "Ana", last_name: "Ruiz", age: 40, stake: "las_americas",
                                   shirt_number: "m", gender: "M", rol: :director)
    sign_in_as(User.create!(email_address: "ana@fsy.com", password: "Directora1!", participant: director))

    get settings_path
    assert_select "#settings-scan", 0

    patch scan_windows_settings_path, params: { arrival: "open" }
    assert_equal "auto", ScanWindow.arrival.mode
  end
end
