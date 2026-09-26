class ParticipantImportsController < ApplicationController
  before_action :require_participant_import!

  def new
  end

  def create
    file = params[:file]
    return redirect_to(new_participant_import_path, alert: "Elegí un archivo para cargar.") if file.blank?

    @import = ParticipantImporter.new(file).call

    if @import.fatal
      flash.now[:alert] = @import.fatal
    elsif @import.imported_count.positive?
      record_audit!(category: :asignaciones, action: "imported", target: nil,
                    summary: "Cargó #{@import.imported_count} #{@import.imported_count == 1 ? 'participante' : 'participantes'} desde un archivo")
    end

    render :new, status: @import.fatal ? :unprocessable_entity : :ok
  end
end
