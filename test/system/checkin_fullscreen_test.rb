require "application_system_test_case"

# En el teléfono la cámara del registro se abre en pantalla completa; el código se escribe desde ahí, y la ✕ o Esc
# (el «atrás» de Android) la cierran sin salir de la página. La cámara es un canvas: la falsa de Chrome no siempre
# abría en el CI, y sin cámara la pantalla completa se cierra sola.
class CheckinFullscreenTest < ApplicationSystemTestCase
  setup do
    ScanWindow.activate!(ScanWindow.arrival)
    Participant.create!(first_name: "Andrea", last_name: "Chavarría", age: 15, stake: "villa_flor",
                        shirt_number: "s", gender: "M", rol: "joven").update_columns(code: "P-0421")
  end

  test "the camera opens full screen on the phone and the code can be typed from there" do
    sign_in_as(users(:one))
    resize_to_mobile
    visit checkins_path
    fake_camera
    click_on "Activar la cámara"
    assert_text "Apunta al código del gafete"
    assert_selector ".scan-viewer[data-fullscreen]"

    click_on "Código"
    within("dialog[data-code-dialog]") do
      fill_in "Código del gafete", with: "421"
      click_on "Registrar"
    end
    within("[data-checkin-scanner-target=card]") do
      assert_text "Andrea Chavarría"
      assert_selector "[data-void-card]", text: "Anular"
    end

    click_on "Salir de pantalla completa"
    assert_no_selector ".scan-viewer[data-fullscreen]"
    assert_current_path checkins_path
    assert_selector "[data-arrived]", text: "1"

    click_on "Pantalla completa"
    assert_selector ".scan-viewer[data-fullscreen]"
    find("body").send_keys(:escape)
    assert_no_selector ".scan-viewer[data-fullscreen]"
    assert_selector "button", text: "Pantalla completa"
  end

  private
    def fake_camera
      page.execute_script(<<~JS)
        navigator.mediaDevices.getUserMedia = async () => {
          const canvas = document.createElement("canvas")
          canvas.width = 640
          canvas.height = 480
          canvas.getContext("2d").fillRect(0, 0, 640, 480)
          return canvas.captureStream(15)
        }
      JS
    end
end
