require "application_system_test_case"

# El joven sale desde «Más» (teléfono) o el menú lateral (computadora), y lo confirma antes: un toque de más
# no lo saca de la app.
class JovenSignOutTest < ApplicationSystemTestCase
  setup do
    @joven = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan))
  end

  teardown do
    page.driver.browser.manage.window.resize_to(1400, 1000)
  end

  test "on the phone, Cerrar sesión in Más asks first and cancelling keeps them in" do
    sign_in_as(@joven, password: "Joven1234!")
    resize_to_mobile
    visit dashboard_path

    find("[data-bottom-nav-item='Más']").click
    find("[data-more-sign-out]").click
    within("dialog[data-confirm-target='modal'][open]") do
      assert_text "¿Cerrar sesión?"
      click_on "Cancelar"
    end
    assert_current_path dashboard_path

    find("[data-bottom-nav-item='Más']").click unless page.has_selector?("dialog[data-dialog-name='mas'][open]", wait: 0)
    find("[data-more-sign-out]").click
    within("dialog[data-confirm-target='modal'][open]") { click_on "Sí, cerrar sesión" }
    assert_current_path new_session_path
  end

  test "on the computer, the side menu's Cerrar sesión asks first too" do
    sign_in_as(@joven, password: "Joven1234!")

    find("[data-aside-sign-out]").click
    within("dialog[data-confirm-target='modal'][open]") { click_on "Sí, cerrar sesión" }
    assert_current_path new_session_path
  end
end
