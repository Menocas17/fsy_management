# Entrar con la huella desde la pantalla de inicio de sesión. La passkey dice de quién es (no se escribe el
# correo); aquí se comprueba su firma con la llave pública guardada y se abre la misma sesión que con la contraseña.
class PasskeySessionsController < ApplicationController
  include PasskeyParams

  allow_unauthenticated_access
  rate_limit to: 20, within: 3.minutes, only: :create, with: -> {
    render json: { error: "Intenta de nuevo más tarde." }, status: :too_many_requests
  }

  def options
    options = WebAuthn::Credential.options_for_get(user_verification: "required", relying_party: relying_party)
    session[:passkey_authentication_challenge] = options.challenge
    render json: options
  end

  def create
    credential = WebAuthn::Credential.from_get(credential_params, relying_party: relying_party)
    passkey = Passkey.includes(:user).find_by(external_id: credential.id)
    return reject unless passkey

    credential.verify(session.delete(:passkey_authentication_challenge), public_key: passkey.public_key,
                      sign_count: passkey.sign_count, user_verification: true)
    user = passkey.user
    # Como con la contraseña: una cuenta que perdió su ficha no entra.
    return reject(user) unless user.linked? && credential.user_handle.in?([ nil, user.webauthn_id ])

    passkey.used!(credential.sign_count)
    LoginAttempt.record!(email: user.email_address, result: :success, request: request, user: user)
    user.signed_in!
    start_new_session_for user
    render json: { location: after_authentication_url }
  rescue WebAuthn::Error
    reject(passkey&.user)
  end

  private
    def reject(user = nil)
      LoginAttempt.record!(email: user&.email_address.to_s, result: :failed, request: request, user: user)
      render json: { error: "No se pudo entrar con la huella. Usa tu correo y contraseña." }, status: :unprocessable_entity
    end
end
