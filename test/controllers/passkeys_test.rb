require "test_helper"
require "webauthn/fake_client"

class PasskeysTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    @client = WebAuthn::FakeClient.new("http://www.example.com")
  end

  def register_passkey
    post options_passkeys_path, as: :json
    options = response.parsed_body
    credential = @client.create(challenge: options["challenge"], user_verified: true)
    post passkeys_path, params: { credential: credential }, as: :json
    options
  end

  def sign_in_with_passkey(user_verified: true)
    post options_passkey_session_path, as: :json
    challenge = response.parsed_body["challenge"]
    credential = @client.get(challenge: challenge, user_verified: user_verified, user_handle: Base64.urlsafe_decode64(@user.reload.webauthn_id))
    post passkey_session_path, params: { credential: credential }, as: :json
    credential
  end

  test "activating it asks for a discoverable passkey with the fingerprint and saves its public key" do
    sign_in_as(@user)
    options = register_passkey

    assert_equal "required", options.dig("authenticatorSelection", "residentKey")
    assert_equal "required", options.dig("authenticatorSelection", "userVerification")
    assert_equal @user.reload.webauthn_id, options.dig("user", "id")
    assert_response :success
    assert_equal settings_path(anchor: "settings-passkeys"), response.parsed_body["location"]
    assert_equal 1, @user.passkeys.count
  end

  test "it lists in Configuración and can be removed" do
    sign_in_as(@user)
    register_passkey

    get settings_path
    assert_select "#settings-passkeys [data-passkey-list] li", 1

    delete passkey_path(@user.passkeys.first)
    assert_redirected_to settings_path(anchor: "settings-passkeys")
    assert_empty @user.passkeys.reload
  end

  test "signing in with it opens a session without email or password" do
    sign_in_as(@user)
    register_passkey
    sign_out

    sign_in_with_passkey
    assert_response :success
    assert_equal dashboard_path, URI.parse(response.parsed_body["location"]).path
    assert_equal 1, @user.sessions.count
    assert @user.passkeys.first.last_used_at
    assert LoginAttempt.result_success.exists?(user: @user)

    get dashboard_path
    assert_response :success
  end

  test "an unverified fingerprint, an unknown passkey or a replayed challenge don't get in" do
    sign_in_as(@user)
    register_passkey
    sign_out

    sign_in_with_passkey(user_verified: false)
    assert_response :unprocessable_entity
    assert_equal 0, @user.sessions.count

    # La misma firma dos veces: el desafío se usa una sola vez.
    credential = sign_in_with_passkey
    assert_response :success
    sign_out
    post passkey_session_path, params: { credential: credential }, as: :json
    assert_response :unprocessable_entity

    @user.passkeys.delete_all
    sign_in_with_passkey
    assert_response :unprocessable_entity
    assert_equal 1, @user.sessions.count
  end

  test "an account that lost its ficha can't use it, and a reset from the ficha removes it" do
    sign_in_as(@user)
    register_passkey
    sign_out

    @user.revoke_password!
    assert_empty @user.passkeys.reload
    sign_in_with_passkey
    assert_response :unprocessable_entity
  end

  test "after a password sign-in the first screen offers it, only once" do
    post session_path, params: { email_address: "maria@fsy.com", password: "Consejera1!" }
    follow_redirect!
    assert_select "dialog[data-passkey-offer]"

    get dashboard_path
    assert_select "dialog[data-passkey-offer]", false
  end

  test "the sign-in screen has the fingerprint button, hidden until the browser supports it" do
    get new_session_path
    assert_select "[data-passkey-target='supported'][hidden] button[data-passkey-sign-in]", text: /Entrar con huella/
    assert_select "input[autocomplete='username webauthn']"
  end

  test "viewing as someone doesn't touch their passkeys" do
    sign_in_as(users(:one))
    post view_as_path, params: { participant_id: participants(:maria).id }

    post options_passkeys_path, as: :json
    assert_response :forbidden
  end
end
