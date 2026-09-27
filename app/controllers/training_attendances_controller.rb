# Marcar o corregir una asistencia a mano, para quien llegó sin gafete o se escaneó por error.
class TrainingAttendancesController < ApplicationController
  before_action :require_checkin_access!
  before_action :set_training

  def create
    participant = Participant.staff.find(params[:participant_id])
    _record, status = TrainingAttendance.register(training: @training, participant: participant,
                                                  recorded_by: Current.user&.participant, source: :manual)

    notice = status == :already ? "#{participant.full_name} ya estaba marcado." : "#{participant.full_name} quedó marcado."
    respond_with_roster(participant, notice)
  end

  def destroy
    attendance = @training.attendances.find(params[:id])
    participant = attendance.participant
    attendance.destroy

    respond_with_roster(participant, "Se quitó la asistencia de #{participant.full_name}.")
  end

  private
    # Desde la ficha de la capacitación se repinta solo el bloque de cifras y listas: se marcan
    # decenas seguidas y recargar la página devolvía la lista al principio cada vez.
    def respond_with_roster(participant, notice)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("training-roster", partial: "trainings/roster",
                                                    locals: { training: @training.reload, highlight: participant.id })
        end
        format.html { redirect_back fallback_location: agenda_training_path(@training), notice: notice }
      end
    end

    def set_training
      @training = Training.find(params[:training_id])
    end
end
