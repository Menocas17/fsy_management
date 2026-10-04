# La carga masiva: se sube el archivo y se va al informe de esa carga, que queda guardado. Las filas con
# problemas se resuelven ahí (ParticipantImportRowsController).
class ParticipantImportsController < ApplicationController
  before_action :require_participant_import!

  def new
    @imports = ParticipantImport.recent.limit(10)
  end

  def create
    file = params[:file]
    return redirect_to(new_participant_import_path, alert: "Elige un archivo para cargar.") if file.blank?

    importer = ParticipantImporter.new(file, uploaded_by: Current.user.participant).call
    if importer.fatal
      @imports = ParticipantImport.recent.limit(10)
      flash.now[:alert] = importer.fatal
      return render :new, status: :unprocessable_entity
    end

    import = importer.import
    record_audit!(category: :participantes, action: "imported", target: nil,
                  summary: "Cargó «#{import.filename}»: #{import.entered_count} entraron, #{import.pending_count} por resolver")
    redirect_to participant_import_path(import), notice: import.pending_count.positive? ? "Carga lista: hay filas por resolver a mano." : "Carga lista."
  end

  def show
    @import = ParticipantImport.find(params[:id])
    @tab = %w[pendientes entraron descartadas].include?(params[:vista]) ? params[:vista] : (@import.pending_count.positive? ? "pendientes" : "entraron")
    statuses = { "pendientes" => :pending, "entraron" => %i[imported approved], "descartadas" => :discarded }.fetch(@tab)
    @rows = @import.rows.where(status: statuses).includes(:participant)
  end
end
