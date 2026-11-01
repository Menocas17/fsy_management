# La carga masiva: se sube el archivo y se va al informe de esa carga, que queda guardado. Las filas con
# problemas se resuelven ahí (ParticipantImportRowsController).
class ParticipantImportsController < ApplicationController
  before_action :require_participant_import!

  # Cuatro pestañas, en el orden en que se cargan: compañías, consejeros (que se sientan en ellas), el resto
  # del staff y jóvenes. Las tres primeras arman el personal: solo con acceso total.
  TABS = %w[companias consejeros staff jovenes].freeze

  def new
    @tab = current_tab
    @imports = ParticipantImport.recent.limit(10)
  end

  def create
    file = params[:file]
    counselors = params[:tipo] == "consejeros" && can_import_staffing?
    staff = params[:tipo] == "staff" && can_import_staffing?
    return redirect_to(new_participant_import_path(tipo: params[:tipo]), alert: "Elige un archivo para cargar.") if file.blank?

    # Sin acceso total (el registro), todas las filas entran como jóvenes, diga lo que diga la columna «Rol»:
    # un Excel no puede crear staff que el formulario no deja crear.
    # El staff toma el rol de su columna «Rol»; la fila que no lo trae es de logística, no un joven.
    role = counselors ? "consejero" : ("joven" unless can_import_staffing?)
    importer = ParticipantImporter.new(file, uploaded_by: Current.user.participant, role: role,
                                       default_role: ("logistica" if staff)).call
    if importer.fatal
      @tab = current_tab
      @imports = ParticipantImport.recent.limit(10)
      flash.now[:alert] = importer.fatal
      return render :new, status: :unprocessable_entity
    end

    import = importer.import
    record_audit!(category: :participantes, action: "imported", target: nil,
                  summary: "Cargó #{"consejeros desde " if counselors}#{"staff desde " if staff}«#{import.filename}»: #{import.entered_count} entraron, #{import.pending_count} por resolver")
    redirect_to participant_import_path(import), notice: import.pending_count.positive? ? "Carga lista: hay filas por resolver a mano." : "Carga lista."
  end

  def show
    @import = ParticipantImport.find(params[:id])
    @tab = %w[pendientes entraron descartadas].include?(params[:vista]) ? params[:vista] : (@import.pending_count.positive? ? "pendientes" : "entraron")
    statuses = { "pendientes" => :pending, "entraron" => %i[imported approved], "descartadas" => :discarded }.fetch(@tab)
    @rows = @import.rows.where(status: statuses).includes(:participant)
  end

  private
    def current_tab
      tab = TABS.include?(params[:tipo]) ? params[:tipo] : "jovenes"
      tab == "jovenes" || can_import_staffing? ? tab : "jovenes"
    end
end
