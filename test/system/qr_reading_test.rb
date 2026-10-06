require "application_system_test_case"

# La lectura del QR (lib/qr_frame): un gafete en medio de un cuadro 1080p, como lo ve la cámara. El worker lee
# sin pausas y sin ocupar el hilo de la pantalla; el hilo principal (el último recurso) deja tiempo entre lecturas.
class QrReadingTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one)
    visit scan_path
  end

  test "the worker reads back to back without blocking the screen" do
    result = read_for_a_second("worker")

    assert_equal "worker", result["engine"]
    assert_equal "P-0421", result["payload"]
    assert_operator result["reads"], :>=, 10, "reads per second"
    assert_operator result["longestFrame"], :<, 100, "the screen never stalls (ms between frames)"
  end

  test "on the main thread it still reads, pausing between reads" do
    result = read_for_a_second("hilo")

    assert_equal "hilo", result["engine"]
    assert_equal "P-0421", result["payload"]
    assert_operator result["reads"], :<=, 9, "at most one read every 120 ms"
  end

  private
    # Lee durante un segundo, una lectura tras otra como el escáner, y cuenta lecturas y el cuadro más largo.
    def read_for_a_second(engine)
      png = Base64.strict_encode64(RQRCode::QRCode.new("P-0421").as_png(size: 240, border_modules: 2).to_s)
      evaluate_async_script(<<~JS, png, engine)
        const [png, engine, done] = arguments
        Promise.all([ import("jsqr"), import("lib/qr_frame") ]).then(async ([ { default: jsQR }, { QrReader } ]) => {
          const image = new Image()
          image.src = `data:image/png;base64,${png}`
          await image.decode()
          const frame = document.createElement("canvas")
          frame.width = 1920
          frame.height = 1080
          const context = frame.getContext("2d")
          context.fillStyle = "#888"
          context.fillRect(0, 0, 1920, 1080)
          context.drawImage(image, 960 - 120, 540 - 120)
          Object.assign(frame, { videoWidth: 1920, videoHeight: 1080, readyState: 4, HAVE_ENOUGH_DATA: 4 })

          const reader = await QrReader.create(() => jsQR, { engine })
          const canvas = document.createElement("canvas")
          let reads = 0, payload = null, longestFrame = 0, last = performance.now()
          const end = last + 1000
          const tick = () => {
            const now = performance.now()
            longestFrame = Math.max(longestFrame, now - last)
            last = now
            if (now >= end) {
              reader.close()
              return done({ engine: reader.engine, reads, payload, longestFrame: Math.round(longestFrame) })
            }
            if (reader.ready(frame)) reader.read(frame, canvas).then((text) => { reads++; payload ||= text })
            requestAnimationFrame(tick)
          }
          requestAnimationFrame(tick)
        })
      JS
    end
end
