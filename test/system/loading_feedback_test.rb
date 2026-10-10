require "application_system_test_case"

# Cambiar de página: sin la barrita de Turbo arriba, y con el círculo de «cargando» solo si la página tarda más de
# 400 ms (application.js). Los eventos de Turbo se disparan a mano para mirar ese instante, que con la red de la
# prueba dura casi nada.
class LoadingFeedbackTest < ApplicationSystemTestCase
  test "a quick page shows nothing; a slow one shows the loading circle until it renders" do
    sign_in_as(users(:one))
    indicator = "[data-page-loading-indicator]"

    execute_script("document.dispatchEvent(new CustomEvent('turbo:visit', { detail: { action: 'advance' } }))")
    assert_equal false, evaluate_script("'pageLoading' in document.documentElement.dataset"), "nothing before 400 ms"
    assert_selector "html[data-page-loading] #{indicator}", visible: :all

    execute_script("document.dispatchEvent(new CustomEvent('turbo:before-render'))")
    assert_no_selector "html[data-page-loading]", visible: :all
  end

  test "going back paints the saved copy at once, without the loading circle" do
    sign_in_as(users(:one))

    execute_script("document.dispatchEvent(new CustomEvent('turbo:visit', { detail: { action: 'restore' } }))")
    sleep 0.6
    assert_no_selector "html[data-page-loading]", visible: :all
  end

  test "Turbo's progress bar stays hidden" do
    sign_in_as(users(:one))
    execute_script("const bar = document.createElement('div'); bar.className = 'turbo-progress-bar'; document.body.append(bar)")

    assert_equal "none", evaluate_script("getComputedStyle(document.querySelector('.turbo-progress-bar')).display")
  end

  # Barra de abajo: la página se pide al apoyar el dedo (pointerdown), sin esperar el click.
  test "touching a bottom bar option starts its visit before the finger lifts, except during the tutorial" do
    sign_in_as(users(:one))
    touch = <<~JS
      document.querySelector('a[data-bottom-nav-item="Agenda"]').dispatchEvent(
        new PointerEvent('pointerdown', { pointerType: 'touch', isPrimary: true, bubbles: true }))
    JS

    execute_script("sessionStorage.setItem('fsy:tour', '{}')")
    execute_script(touch)
    sleep 0.5
    assert_current_path dashboard_path

    execute_script("sessionStorage.removeItem('fsy:tour')")
    execute_script(touch)
    assert_current_path agenda_path
    assert_selector "a[data-bottom-nav-item='Agenda'][data-turbo-prefetch='false']", visible: :all
  end
end
