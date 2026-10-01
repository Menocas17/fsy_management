require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "inicia sesión con el correo y la contraseña y llega al panel" do
    sign_in_as(users(:one))

    assert_title(/Panel general/)
  end

  test "una contraseña equivocada se queda en el inicio de sesión con un aviso" do
    visit new_session_path
    fill_in "Correo electrónico", with: users(:one).email_address
    fill_in "Contraseña", with: "equivocada"
    click_on "Entrar"

    assert_text "Intenta otro correo o contraseña"
    assert_current_path new_session_path
  end

  test "después de iniciar sesión vuelve a la página que se pidió" do
    visit participants_path
    assert_current_path new_session_path

    fill_in "Correo electrónico", with: users(:one).email_address
    fill_in "Contraseña", with: "password"
    click_on "Entrar"

    assert_current_path participants_path
  end

  test "cerrar sesión desde el menú de cuenta vuelve a pedir la contraseña" do
    sign_in_as(users(:one))

    find("button[aria-label='Menú de cuenta']").click
    click_on "Cerrar sesión"
    assert_current_path new_session_path

    visit dashboard_path
    assert_current_path new_session_path
  end
end
