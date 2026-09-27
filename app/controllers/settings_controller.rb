class SettingsController < ApplicationController
  rate_limit to: 5, within: 3.minutes, only: :send_password_reset,
             with: -> { redirect_to settings_path, alert: "Intenta de nuevo más tarde." }

  before_action :require_superadmin!, only: :scan_windows

  def show
    @trainings = Training.chronological if Current.user.superadmin?
  end

  # Abrir o cerrar a mano el escaneo de la llegada y de cada capacitación. Por defecto, solo el día.
  def scan_windows
    arrival = params[:arrival].to_s
    AppSetting[ScanWindow::ARRIVAL_KEY] = arrival if ScanWindow::MODES.key?(arrival)

    params.fetch(:trainings, {}).each do |id, mode|
      Training.find(id).update!(scan_mode: mode) if ScanWindow::MODES.key?(mode.to_s)
    end

    redirect_to settings_path(anchor: "settings-scan"), notice: "Se guardó cuándo se puede escanear cada registro."
  end

  def send_password_reset
    PasswordsMailer.reset(Current.user).deliver_later
    redirect_to settings_path, notice: "Se ha enviado el enlace de recuperación a #{Current.user.email_address}."
  end

  private
    def require_superadmin!
      redirect_to settings_path, alert: "Solo el administrador del sistema abre o cierra los registros." unless Current.user.superadmin?
    end
end
