require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    post passwords_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Se han enviado las instrucciones para restablecer la contraseña."
  end

  test "create for an unknown user redirects but sends no mail" do
    post passwords_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Se han enviado las instrucciones para restablecer la contraseña."
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice "El enlace para restablecer la contraseña no es válido o ha caducado."
  end

  test "update" do
    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "StrongPassword123!", password_confirmation: "StrongPassword123!" }
      assert_redirected_to new_session_path
    end

    follow_redirect!
    assert_notice "La contraseña ha sido restablecida."
  end

  test "update with non matching passwords stays on the form and says why" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "StrongPassword123!", password_confirmation: "Otra123!" }
      assert_response :unprocessable_entity
    end

    assert_select "[role=alert] li", text: "La confirmación de la contraseña no coincide"
  end

  test "update names the rule a weak password breaks, not a mismatch" do
    put password_path(@user.password_reset_token), params: { password: "debil", password_confirmation: "debil" }

    assert_response :unprocessable_entity
    assert_select "[role=alert] li", text: "La contraseña debe tener al menos 8 caracteres"
    assert_select "[role=alert] li", text: /no coincide/, count: 0
  end

  test "update with a blank password changes nothing" do
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "", password_confirmation: "" }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert] li", text: "La contraseña no puede estar en blanco"
  end

  test "the emailed link also opens with a session already open" do
    sign_in_as(@user)

    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "without email configured, the forgot-password page sends you back to sign in" do
    with_password_reset_emails(false) do
      get new_password_path
      assert_redirected_to new_session_path

      post passwords_path, params: { email_address: @user.email_address }
      assert_redirected_to new_session_path
      assert_enqueued_emails 0

      get new_session_path
      assert_select "a[href='#{new_password_path}']", 0
      assert_includes response.body, "Pídele a tu coordinación que la restablezca"
    end
  end

  private
    def with_password_reset_emails(enabled)
      previous = Rails.configuration.x.password_reset_emails
      Rails.configuration.x.password_reset_emails = enabled
      yield
    ensure
      Rails.configuration.x.password_reset_emails = previous
    end

    def assert_notice(text)
      assert_select "div", /#{text}/
    end
end
