require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # CHROME_BIN apunta a otro Chrome/Chromium cuando el del sistema no sirve (p. ej. un contenedor sin Chrome).
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ] do |options|
    options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
    # Chrome no arranca su sandbox como root (contenedores); fuera de ellos esto no aplica.
    options.add_argument("--no-sandbox") if Process.uid.zero?
  end

  # Entra por el formulario real, no por la cookie: así la prueba también cubre el inicio de sesión.
  def sign_in_as(user, password: "password")
    visit new_session_path
    fill_in "Correo electrónico", with: user.email_address
    fill_in "Contraseña", with: password
    click_on "Entrar"
    assert_current_path dashboard_path
  end

  # El ancho de un celular común, para las pruebas que cuidan el diseño en pantallas angostas.
  def resize_to_mobile
    page.driver.browser.manage.window.resize_to(390, 844)
  end
end
