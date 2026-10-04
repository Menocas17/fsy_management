# Subir las compañías desde un Excel (CompanyImporter), en la misma pantalla de la carga masiva: primero
# las compañías, después los consejeros que se sientan en ellas y al final los jóvenes.
class CompanyImportsController < ApplicationController
  before_action :require_staffing_import!

  def create
    return redirect_to(new_participant_import_path(tipo: "companias"), alert: "Elige un archivo para cargar.") if params[:file].blank?

    @result = CompanyImporter.new(params[:file]).call
    unless @result.fatal
      record_audit!(category: :companias, action: "imported", target: nil,
                    summary: "Cargó compañías desde «#{params[:file].original_filename}»: #{@result.summary.downcase}")
    end
    return redirect_to(new_participant_import_path(tipo: "companias"), notice: "#{@result.summary}.") if @result.fatal.nil? && @result.errors.empty?

    @tab = "companias"
    @imports = ParticipantImport.recent.limit(10)
    flash.now[:alert] = @result.fatal || "#{@result.summary}. Algunas filas no entraron: abajo dice por qué."
    render "participant_imports/new", status: :unprocessable_entity
  end

  private
    def require_staffing_import!
      redirect_to dashboard_path, alert: "Las compañías las carga quien tiene acceso total" unless can_import_staffing?
    end
end
