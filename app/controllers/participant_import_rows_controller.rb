# Resolver a mano una fila en espera de una carga masiva: corregirla, aprobarla (entra a la base con su
# asignación, si ya nada la bloquea) o descartarla. Siempre se vuelve al informe de la carga.
class ParticipantImportRowsController < ApplicationController
  before_action :require_participant_import!
  before_action :set_row

  def edit
  end

  def update
    values = @row.values.merge(params.expect(row: ParticipantImportRow::EDITABLE.keys).to_h.transform_values(&:presence))
    @row.update!(values: values)
    @row.reevaluate!
    redirect_to back_to_report, notice: @row.blocking? ? "Guardado. Todavía tiene algo que resolver." : "Guardado: ya se puede aprobar."
  end

  def approve
    if @row.approve!(actor_name)
      record_audit!(category: :participantes, action: "created", target: @row.participant,
                    summary: "Aprobó a #{@row.participant.full_name} desde la carga «#{@import.filename}»")
      redirect_to back_to_report, notice: "#{@row.participant.full_name} entró a la base."
    else
      redirect_to back_to_report, alert: "#{@row.name} todavía tiene algo que resolver: corrígelo antes de aprobar."
    end
  end

  def discard
    @row.discard!(actor_name)
    redirect_to back_to_report, notice: "Se descartó la fila #{@row.row_number} (#{@row.name})."
  end

  private
    def set_row
      @import = ParticipantImport.find(params[:participant_import_id])
      @row = @import.rows.pending.find(params[:id])
    end

    def actor_name
      Current.user.participant&.full_name || "Administrador del sistema"
    end

    def back_to_report
      participant_import_path(@import, anchor: "fila-#{@row.row_number}")
    end
end
