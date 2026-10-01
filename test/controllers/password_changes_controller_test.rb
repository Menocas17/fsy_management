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

  test "an account on the default password can only change it or sign out" do
    joven = participants(:juan)
    account = User.create_for_participant(joven, email: "juan@fsy.com", email_confirmation: "juan@fsy.com")

    post session_path, params: { email_address: "juan@fsy.com", password: User::DEFAULT_PASSWORD }
    follow_redirect!
    assert_redirected_to edit_password_change_path

    get participant_path(joven)
    assert_redirected_to edit_password_change_path

    get count_notifications_path, as: :json
    assert_response :forbidden

    get edit_password_change_path
    assert_select "[data-password-change='forced']"
    assert_select "input[name='password_challenge']", 0, "they just typed the default one"
    assert_select "form[action='#{session_path}']", text: /Cerrar sesión/

    patch password_change_path, params: { password: "MiClave2027!", password_confirmation: "MiClave2027!" }
    assert_redirected_to participant_url(joven), "back to where they were going"
    assert_not account.reload.must_change_password?
    assert account.authenticate("MiClave2027!")

    get participant_path(joven)
    assert_response :success
  end

  test "the new one cannot be the default password again" do
    account = User.create_for_participant(participants(:juan), email: "juan@fsy.com", email_confirmation: "juan@fsy.com")
    sign_in_as(account)

    patch password_change_path, params: { password: User::DEFAULT_PASSWORD, password_confirmation: User::DEFAULT_PASSWORD }

    assert_response :unprocessable_entity
    assert_select "[role=alert] li", text: /no puede ser la contraseña predeterminada/
    assert_select "[data-password-change='forced']", 1, "still the forced form"
    assert account.reload.must_change_password?
  end

  test "signing out works while the change is pending" do
    account = User.create_for_participant(participants(:juan), email: "juan@fsy.com", email_confirmation: "juan@fsy.com")
    sign_in_as(account)

    delete session_path

    assert_redirected_to new_session_path
    assert_equal 0, account.sessions.count
  end

  test "an emailed reset also clears the pending change" do
    account = User.create_for_participant(participants(:juan), email: "juan@fsy.com", email_confirmation: "juan@fsy.com")

    put password_path(account.password_reset_token), params: { password: "MiClave2027!", password_confirmation: "MiClave2027!" }

    assert_redirected_to new_session_path
    assert_not account.reload.must_change_password?
  end
end
