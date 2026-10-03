require "test_helper"

class PasswordChangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
  end

  test "asks to sign in first" do
    get edit_password_change_path
    assert_redirected_to new_session_path
  end

  test "Configuración links to the change instead of emailing a reset" do
    sign_in_as(@user)

    get settings_path
    assert_select "a[href='#{edit_password_change_path}']", text: /Cambiar contraseña/
  end

  test "changing it with the current password closes the other sessions but keeps this one" do
    other_device = @user.sessions.create!
    sign_in_as(@user)
    this_device = Current.session

    patch password_change_path, params: { password_challenge: "Consejera1!", password: "NuevaClave2!", password_confirmation: "NuevaClave2!" }

    assert_redirected_to settings_path
    assert @user.reload.authenticate("NuevaClave2!")
    assert_not Session.exists?(other_device.id)
    assert Session.exists?(this_device.id)
  end

  test "a wrong or missing current password changes nothing" do
    sign_in_as(@user)

    [ { password_challenge: "equivocada" }, {} ].each do |challenge|
      assert_no_changes -> { @user.reload.password_digest } do
        patch password_change_path, params: { password: "NuevaClave2!", password_confirmation: "NuevaClave2!" }.merge(challenge)
      end
      assert_response :unprocessable_entity
      assert_select "[role=alert] li", text: "La contraseña actual no es correcta"
    end
  end

  test "the new password still has to follow the rules and match" do
    sign_in_as(@user)

    patch password_change_path, params: { password_challenge: "Consejera1!", password: "nueva", password_confirmation: "otra" }

    assert_response :unprocessable_entity
    assert_select "[role=alert] li", text: "La confirmación de la contraseña no coincide"
    assert_select "[role=alert] li", text: /al menos una letra mayúscula/
    assert @user.reload.authenticate("Consejera1!")
  end
end
