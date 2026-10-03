class PasswordsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access
  before_action :require_password_reset_emails, only: %i[ new create ]
  before_action :set_user_by_token, only: %i[ edit update ]
  # El enlace del correo se puede abrir con la sesión abierta: es quien pidió cambiarla, no hay a dónde mandarlo.
  before_action :redirect_if_authenticated, only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Intenta de nuevo más tarde" }
  rate_limit to: 10, within: 3.minutes, only: :update, name: "update",
             with: -> { redirect_to new_session_path, alert: "Intenta de nuevo más tarde" }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Se han enviado las instrucciones para restablecer la contraseña (si existe un usuario con esa dirección de correo electrónico)."
  end

  def edit
  end

  # Si falla, se queda en el formulario con los motivos (antes redirigía y todo error decía «no coinciden»).
  def update
    if params[:password].blank?
      @user.errors.add(:password, :blank)
    elsif @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      return redirect_to new_session_path, notice: "La contraseña ha sido restablecida."
    end

    render :edit, status: :unprocessable_entity
  end

  private
    # El enlace de «¿Olvidaste tu contraseña?» (vale minutos) o el de la invitación al crear o restablecer
    # la cuenta desde la ficha (vale días). Los dos dejan de servir en cuanto se cambia la contraseña.
    def set_user_by_token
      @welcome = params[:bienvenida].present?
      @user = User.find_by_token_for(:invitation, params[:token]) || User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to password_reset_emails? ? new_password_path : new_session_path,
                  alert: "El enlace para restablecer la contraseña no es válido o ha caducado."
    end

    def require_password_reset_emails
      return if password_reset_emails?

      redirect_to new_session_path, alert: "Por ahora la contraseña no se recupera por correo: pídele a tu coordinación que te mande un enlace nuevo desde tu ficha."
    end

    def redirect_if_authenticated
      redirect_to dashboard_path if authenticated?
    end
end
