class SettingsController < ApplicationController
  rate_limit to: 5, within: 3.minutes, only: :send_password_reset,
             with: -> { redirect_to settings_path, alert: "Intenta de nuevo más tarde." }

  def show
  end

  def send_password_reset
    PasswordsMailer.reset(Current.user).deliver_later
    redirect_to settings_path, notice: "Se ha enviado el enlace de recuperación a #{Current.user.email_address}."
  end
end
