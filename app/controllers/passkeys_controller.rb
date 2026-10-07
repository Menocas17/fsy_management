# Activar y quitar la entrada con huella de la propia cuenta (Configuración → Entrar con huella). El
# navegador pide la huella, crea la passkey y aquí se guarda su llave pública (Passkey).
class PasskeysController < ApplicationController
  include PasskeyParams

  before_action :forbid_view_as

  # Las opciones para navigator.credentials.create: el desafío queda en la sesión hasta que vuelva firmado.
  def options
    user = Current.user
    options = WebAuthn::Credential.options_for_create(
      user: { id: user.webauthn_handle!, name: user.email_address, display_name: user.full_name },
      exclude: user.passkeys.pluck(:external_id),
      # resident_key: la passkey sabe de quién es, así se entra sin escribir el correo.
      authenticator_selection: { resident_key: "required", user_verification: "required" },
      relying_party: relying_party
    )
    session[:passkey_registration_challenge] = options.challenge
    render json: options
  end

  def create
    credential = WebAuthn::Credential.from_create(credential_params, relying_party: relying_party)
    credential.verify(session.delete(:passkey_registration_challenge), user_verification: true)

    Current.user.passkeys.create!(external_id: credential.id, public_key: credential.public_key,
                                  sign_count: credential.sign_count, name: Passkey.name_for(request.user_agent))
    flash[:notice] = "Listo: la próxima vez entra con tu huella."
    render json: { location: settings_path(anchor: "settings-passkeys") }
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid
    render json: { error: "No se pudo activar la huella. Intenta de nuevo." }, status: :unprocessable_entity
  end

  def destroy
    Current.user.passkeys.find(params[:id]).destroy!
    redirect_to settings_path(anchor: "settings-passkeys"), notice: "Se quitó la huella de ese dispositivo."
  end

  private
    # Viendo como otra persona no se tocan sus llaves: la cuenta es suya.
    def forbid_view_as
      return unless Current.viewing_as?

      message = "Viendo como otra persona no se cambia su entrada con huella."
      request.format.json? ? render(json: { error: message }, status: :forbidden) : redirect_to(settings_path, alert: message)
    end
end
