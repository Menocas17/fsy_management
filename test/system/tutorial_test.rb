require "application_system_test_case"

# El tutorial de punta a punta en un teléfono, con toques de verdad sobre lo iluminado: la consejera lo
# recorre entero (enfermería y Conteo con los jóvenes de práctica), y nada de lo practicado se guarda.
class TutorialTest < ApplicationSystemTestCase
  setup do
    Rails.configuration.x.tutorial_autostart = true
    @company = Company.create!(number: 7)
    participants(:juan).update!(company: @company)
    Membership.create!(associable: @company, participant: participants(:maria))
    @counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    Activity.create!(title: "Servicio comunitario", category: :actividad, location: "La Rotonda",
                     date: Rails.configuration.x.event_start_on.to_s, start_time: "10:00", end_time: "12:30", counselors_notes: "Llevar agua")
  end

  teardown do
    Rails.configuration.x.tutorial_autostart = false
    cdp("Emulation.clearDeviceMetricsOverride")
    cdp("Emulation.setTouchEmulationEnabled", enabled: false)
  end

  test "a counselor walks the whole tutorial and nothing practiced is saved" do
    emulate_phone
    sign_in_as(@counselor, password: "Consejera1!")

    expect "Hola, María"
    go_on
    expect "Tus cifras de un vistazo"
    go_on
    expect "Tu compañía"
    tap_target
    expect "La ficha de un joven"
    assert_selector "[data-practice-jovenes]"
    tap_target
    expect "¿Lo llevas a enfermería?"
    tap_target
    expect "Su ficha de enfermería"
    tap_target
    expect "Elige el motivo"
    first("[data-infirmary-form] label:has(input[type=radio])").click
    go_on
    expect "Avisa que lo llevas"
    tap_target
    expect "Práctica: enfermería no recibió nada"
    assert_equal 0, InfirmaryVisit.count
    go_on

    expect "Tu código QR"
    go_on
    expect "La agenda"
    tap_target
    expect "Despliega una actividad"
    tap_target
    expect "Todo lo de esa actividad"
    go_on

    expect "La campanita"
    tap_target
    expect "Desliza para borrar"
    within("[data-alert-tutorial]") { find("[data-alert-swipe-delete]", visible: :all).execute_script("this.click()") }
    expect "Esta sí se borró"
    go_on

    expect "Más opciones"
    tap_target
    expect "Escanear gafete"
    tap_target
    expect "La ficha de cualquier joven"
    go_on

    expect "El Conteo"
    tap_target
    expect "Abre el Conteo"
    tap_target
    expect "Marca a cada joven"
    all("[data-night-toggle]").each(&:click)
    go_on
    expect "Confirma la lista"
    tap_target
    expect "Práctica: la lista no se guardó"
    assert_equal 0, NightAttendance.count
    go_on

    expect "Tu cuenta"
    tap_target
    expect "Configuración"
    tap_target
    expect "Modo oscuro"
    go_on
    expect "Modo simple"
    find("#settings-simple button[role=switch]").click
    within(".tour-coach") { assert_text "Lo cambias cuando termines el tutorial" }
    assert @counselor.reload.simple_mode?
    go_on
    expect "Activa las notificaciones"
    assert_selector "[data-tour='push'] button", text: "Activar en este dispositivo"
    go_on

    expect "¡Listo para la semana!"
    within(".tour-coach") { click_on "Cerrar" }
    assert_no_selector ".tour-coach"
    assert_predicate @counselor.reload.tutorial_completed_at, :present?
    assert_not Alert.source_tutorial.exists?, "la alerta de práctica se va al terminar"
  end

  test "the director practices deleting a training and sending an alert, and neither is saved" do
    training = Training.create!(name: "Primera capacitación", held_on: Date.current)
    director = Participant.create!(first_name: "Ana", last_name: "Ruiz", age: 40, stake: "las_americas", ward: "las_mercedes",
                                   shirt_number: "m", gender: "M", rol: :director)
    User.create!(email_address: "ana@fsy.com", password: "Directora1!", participant: director)
    emulate_phone
    sign_in_as(director.user, password: "Directora1!")

    expect "Hola, Ana"
    go_on
    expect "Tus cifras de un vistazo"
    go_on
    expect "Todas las compañías"
    go_on
    expect "Busca cualquier cosa"
    go_on
    expect "La agenda"
    tap_target
    expect "Despliega una actividad"
    tap_target
    expect "Todo lo de esa actividad"
    go_on
    expect "Capacitaciones"
    tap_target
    expect "Borra deslizando"
    find("[data-training-swipe-delete]", visible: :all).execute_script("this.click()")
    expect "Práctica: no se borró"
    assert Training.exists?(training.id)
    go_on

    expect "La campanita"
    tap_target
    expect "Desliza para borrar"
    within("[data-alert-tutorial]") { find("[data-alert-swipe-delete]", visible: :all).execute_script("this.click()") }
    expect "Esta sí se borró"
    go_on
    expect "Más opciones"
    tap_target
    expect "Escanear gafete"
    tap_target
    expect "La ficha de cualquier joven"
    go_on

    expect "Enviar una alerta"
    go_on
    expect "Envíala"
    assert_no_difference -> { Alert.sent.count } do
      tap_target
      expect "Práctica: no le llegó a nadie"
    end
    go_on
    expect "Tu cuenta"
  end

  test "skipping closes it for good" do
    emulate_phone
    sign_in_as(@counselor, password: "Consejera1!")
    expect "Hola, María"
    within(".tour-coach") { click_on "Saltar" }
    assert_no_selector ".tour-coach"
    assert_predicate @counselor.reload.tutorial_completed_at, :present?

    visit dashboard_path
    assert_no_selector ".tour-coach"
  end

  private
    def expect(title)
      within(".tour-coach") { assert_selector "h2", text: title }
      settle
    end

    # Espera a que el foco deje de moverse (el desplazamiento suave y su transición).
    def settle
      last = nil
      20.times do
        rect = evaluate_script("(() => { const r = document.querySelector('.tour-spot')?.getBoundingClientRect(); return r ? [Math.round(r.x), Math.round(r.y), Math.round(r.width)] : null })()")
        break if rect == last && rect

        last = rect
        sleep 0.15
      end
      sleep 0.1
    end

    def go_on
      within(".tour-coach") { find("[data-tour-act='next']").click }
    end

    # Toca el centro de lo iluminado, como un dedo: lo que recibe el toque es lo que está ahí.
    def tap_target
      spot = find(".tour-spot", visible: :all).rect
      x = spot.x + spot.width / 2
      y = spot.y + spot.height / 2
      cdp("Input.dispatchMouseEvent", type: "mousePressed", x: x, y: y, button: "left", clickCount: 1)
      cdp("Input.dispatchMouseEvent", type: "mouseReleased", x: x, y: y, button: "left", clickCount: 1)
    end

    def emulate_phone
      cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 2, mobile: true, screenWidth: 390, screenHeight: 844)
      cdp("Emulation.setTouchEmulationEnabled", enabled: true, maxTouchPoints: 1)
    end

    def cdp(command, **params)
      page.driver.browser.execute_cdp(command, **params)
    end
end
