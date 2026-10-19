class SettingsController < ApplicationController
  before_action :require_scan_manager!, only: :scan_windows
  before_action :require_company_reveal_manager!, only: :company_reveal
  # Tiene su propio aviso viendo como otro (abajo).
  skip_before_action :block_writes_while_viewing_as, only: :simple_mode

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

  # Abrir o cerrar a los consejeros su compañía (CompanyReveal). Al abrirla les llega un aviso a todos.
  def company_reveal
    open = params[:abrir] == "1"
    if open != CompanyReveal.open?
      open ? CompanyReveal.open! : CompanyReveal.close!
      record_audit!(category: :companias, action: open ? "companies_opened" : "companies_closed", target: nil,
                    summary: open ? "Abrió las compañías a los consejeros: ven a su compañero(a) y a sus jóvenes" :
                                    "Cerró las compañías a los consejeros: solo ven su compañía en cifras")
      if open
        sender = Current.user.participant
        CompanyReveal.announce!(sender: sender, sender_name: sender&.full_name || "Dirección")
      end
    end
    notice = open ? "Compañías abiertas: los consejeros ya ven a su compañero(a) y a sus jóvenes." :
                    "Compañías cerradas: los consejeros solo ven su compañía en cifras."
    redirect_to settings_path(anchor: "settings-companies"), notice: notice
  end

  private
    def require_company_reveal_manager!
      redirect_to settings_path, alert: "Solo dirección y los coordinadores abren o cierran las compañías." unless Current.user.company_reveal_manager?
    end

    def require_scan_manager!
      redirect_to settings_path, alert: "Solo el director de logística o el administrador activan los registros." unless Current.user.scan_manager?
    end
end
