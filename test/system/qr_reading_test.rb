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
    # Que no pare entre lecturas, no cuántas hace: eso depende de la CPU, y en el CI las pruebas de sistema corren
    # en paralelo y otro Chrome se la quita (bajaba de 13 a 6 lecturas). El hilo principal espera 120 ms o más.
    assert_operator result["reads"], :>=, 3, "reads again and again"
    assert_operator result["longestGap"], :<, 100, "starts the next read without a pause (ms)"
    assert_operator result["longestFrame"], :<, 100, "the screen never stalls (ms between frames)"
  end

  test "on the main thread it still reads, pausing between reads" do
    result = read_for_a_second("hilo")

    assert_equal "hilo", result["engine"]
    assert_equal "P-0421", result["payload"]
    # Con la CPU del CI repartida entre cuatro Chrome, una lectura en el hilo principal puede tardar casi el
    # segundo entero: se sigue leyendo hasta tener dos (sin una segunda no hay pausa que medir).
    assert_operator result["reads"], :>=, 2, "reads more than once"
    assert_operator result["reads"], :<=, result["elapsed"] / 120 + 1, "at most one read every 120 ms"
    assert_operator result["longestGap"], :>=, 100, "pauses between reads (ms)"
  end

  private
    # Lee durante un segundo (y, si hasta ahí terminó menos de dos lecturas, hasta tener dos, como mucho 6 s), una
    # lectura tras otra como el escáner, y cuenta lecturas, el cuadro más largo y la pausa más larga entre el fin
    # de una lectura y el comienzo de la siguiente.
    def read_for_a_second(engine)
      png = Base64.strict_encode64(RQRCode::QRCode.new("P-0421").as_png(size: 240, border_modules: 2).to_s)
      # El guion puede seguir hasta 6 s: Capybara le da al script asíncrono su tiempo de espera, 2 s por defecto.
      using_wait_time(10) { evaluate_async_script(<<~JS, png, engine) }
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
          let reads = 0, payload = null, longestFrame = 0, longestGap = 0, finished = null, last = performance.now()
          const start = last, end = start + 1000, limit = start + 6000
          const tick = () => {
            const now = performance.now()
            longestFrame = Math.max(longestFrame, now - last)
            last = now
            if ((now >= end && reads >= 2) || now >= limit) {
              reader.close()
              return done({ engine: reader.engine, reads, payload, elapsed: Math.round(now - start),
                            longestFrame: Math.round(longestFrame), longestGap: Math.round(longestGap) })
            }
            if (reader.ready(frame)) {
              if (finished !== null) longestGap = Math.max(longestGap, now - finished)
              reader.read(frame, canvas).then((text) => { reads++; payload ||= text; finished = performance.now() })
            }
            requestAnimationFrame(tick)
          }
          requestAnimationFrame(tick)
        })
      JS
    end
end
