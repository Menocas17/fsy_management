require "application_system_test_case"

# La lectura del QR (lib/qr_frame): toma el centro del cuadro a su resolución real y deja tiempo libre al
# teléfono entre lectura y lectura. Un cuadro 1080p con el gafete en medio, como lo ve la cámara.
class QrReadingTest < ApplicationSystemTestCase
  setup { sign_in_as users(:one) }

  test "reads a badge in the middle of a 1080p frame and schedules the next read" do
    visit scan_path
    png = Base64.strict_encode64(RQRCode::QRCode.new("P-0421").as_png(size: 240, border_modules: 2).to_s)

    result = evaluate_async_script(<<~JS, png)
      const [png, done] = arguments
      Promise.all([import("jsqr"), import("lib/qr_frame")]).then(([{ default: jsQR }, { readCenter, readyToRead }]) => {
        const image = new Image()
        image.onload = () => {
          const frame = document.createElement("canvas")
          frame.width = 1920
          frame.height = 1080
          const context = frame.getContext("2d")
          context.fillStyle = "#888"
          context.fillRect(0, 0, 1920, 1080)
          context.drawImage(image, 960 - 120, 540 - 120)
          // Un cuadro de video que se puede leer, con las medidas de uno.
          Object.assign(frame, { videoWidth: 1920, videoHeight: 1080, readyState: 4, HAVE_ENOUGH_DATA: 4 })

          const state = {}
          const before = readyToRead(state, frame)
          const payload = readCenter(jsQR, frame, document.createElement("canvas"), state)
          done({ before, payload, after: readyToRead(state, frame), waits: state.nextAt - performance.now() })
        }
        image.src = `data:image/png;base64,${png}`
      })
    JS

    assert result["before"]
    assert_equal "P-0421", result["payload"]
    assert_not result["after"], "right after a read it waits before the next one"
    assert_operator result["waits"], :>, 50
  end
end
