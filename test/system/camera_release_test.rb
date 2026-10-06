require "application_system_test_case"

# Salir del escáner apaga la cámara, aunque se salga mientras todavía se estaba encendiendo (en el teléfono
# tarda): antes quedaba prendida en segundo plano, sin pantalla que la apagara. La cámara es de mentira (un
# canvas) y tarda 600 ms en llegar; cada una que se entrega queda anotada para revisar que terminó apagada.
class CameraReleaseTest < ApplicationSystemTestCase
  setup { sign_in_as users(:one) }

  test "leaving the panel scanner while the camera is still starting turns it off" do
    visit scan_path
    leave_while_starting("qr-scanner")
    assert_all_cameras_off
  end

  test "leaving the check-in scanner while the camera is still starting turns it off" do
    ScanWindow.activate!(ScanWindow.arrival)
    visit checkins_path
    leave_while_starting("checkin-scanner")
    assert_all_cameras_off
  end

  test "leaving after the camera is on turns it off too" do
    visit scan_path
    fake_slow_camera
    find("[data-action='qr-scanner#start']").click
    assert_text "Apunta"
    assert_equal [ "live" ], page.evaluate_script("window.cameras.map((stream) => stream.getTracks()[0].readyState)")

    page.execute_script("Turbo.visit('#{dashboard_path}')")
    assert_current_path dashboard_path
    assert_all_cameras_off
  end

  private
    def fake_slow_camera
      page.execute_script(<<~JS)
        window.cameras = []
        navigator.mediaDevices.getUserMedia = () => new Promise((resolve) => setTimeout(() => {
          const canvas = document.createElement("canvas")
          canvas.width = 640
          canvas.height = 480
          canvas.getContext("2d").fillRect(0, 0, 640, 480)
          const stream = canvas.captureStream(15)
          window.cameras.push(stream)
          resolve(stream)
        }, 600))
      JS
    end

    def leave_while_starting(controller)
      fake_slow_camera
      find("[data-action='#{controller}#start']").click
      page.execute_script("Turbo.visit('#{dashboard_path}')")
      assert_current_path dashboard_path
      sleep 1.2 # a que llegue la cámara que se pidió
    end

    def assert_all_cameras_off
      states = page.evaluate_script("window.cameras.map((stream) => stream.getTracks()[0].readyState)")
      assert_not_empty states, "a camera was handed over"
      assert_equal [ "ended" ], states.uniq, "every camera ends up off"
    end
end
