class SettingsController < ApplicationController
  before_action :require_scan_manager!, only: :scan_windows

  def show
    @trainings = Training.chronological if Current.user.scan_manager?
  end

  # Activa un registro (la llegada o una capacitación) y cierra el que estaba; scan vacío los cierra todos.
  def scan_windows
    scan = params[:scan].to_s
    training = Training.find_by(id: scan.delete_prefix("training:")) if scan.start_with?("training:")
    window = scan == "arrival" ? ScanWindow.arrival : (training && ScanWindow.for(training))

    ScanWindow.activate!(window)
    notice = window ? "Se activó el registro de #{training&.name || "la llegada"}." : "Se cerró el registro por escaneo."
    redirect_to settings_path(anchor: "settings-scan"), notice: notice
  end

  # Encender o apagar el modo simple de la propia cuenta. Viendo como otro no se guarda: la cuenta es de esa persona.
  def simple_mode
    if Current.viewing_as?
      redirect_to settings_path, alert: "Viendo como otra persona no se cambia su modo simple."
    else
      Current.user.update!(simple_mode: params[:simple_mode] == "1")
      notice = Current.user.simple_mode? ? "Modo simple encendido." : "Modo simple apagado: ves el menú completo."
      redirect_to settings_path(anchor: "settings-simple"), notice: notice
    end
  end

  private
    def require_scan_manager!
      redirect_to settings_path, alert: "Solo el director de logística o el administrador activan los registros." unless Current.user.scan_manager?
    end
end
