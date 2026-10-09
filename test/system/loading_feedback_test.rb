require "application_system_test_case"

# Que se note el avance: la barra de progreso sale pronto, y la opción del menú tocada se marca antes de que
# llegue la página (application.js). El turbo:click se dispara a mano para mirar el instante entre el toque y
# la página nueva, que con la red de la prueba dura casi nada.
class LoadingFeedbackTest < ApplicationSystemTestCase
  test "the progress bar shows after 150 ms instead of Turbo's 500" do
    sign_in_as(users(:one))

    assert_equal 150, evaluate_script("Turbo.config.drive.progressBarDelay")
  end

  test "the tapped menu option lights up before its page arrives, and the snapshot keeps no trace" do
    sign_in_as(users(:one))
    agenda = "aside [data-nav-link][href='#{agenda_path}']"
    assert_selector "aside [data-nav-link][aria-current=page]", text: "Inicio"

    execute_script("document.querySelector(arguments[0]).dispatchEvent(new CustomEvent('turbo:click', { bubbles: true }))", agenda)
    assert_selector "#{agenda}[data-nav-pending]"
    assert_selector "aside nav[data-nav-switching]"

    # Lo ya abierto no se marca.
    execute_script("document.querySelector('aside [data-nav-link][aria-current=page]').dispatchEvent(new CustomEvent('turbo:click', { bubbles: true }))")
    assert_selector "#{agenda}[data-nav-pending]"

    execute_script("document.dispatchEvent(new CustomEvent('turbo:before-cache'))")
    assert_no_selector "[data-nav-pending]"
    assert_no_selector "[data-nav-switching]"
  end
end
