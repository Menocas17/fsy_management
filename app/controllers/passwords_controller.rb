class PasswordsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
   before_action :redirect_if_authenticated, only: %i[ new create edit]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Intenta de nuevo mas tarde" }

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

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "La contraseña ha sido restablecida."
    else
      redirect_to edit_password_path(params[:token]), alert: "Las contraseñas no coinciden."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "El enlace para restablecer la contraseña no es válido o ha caducado."
    end

  def redirect_if_authenticated
    redirect_to dashboard_path if authenticated?
  end
end
