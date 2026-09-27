# Marcar o corregir una asistencia a mano, para quien llegó sin gafete o se escaneó por error.
class TrainingAttendancesController < ApplicationController
  before_action :require_checkin_access!
  before_action :set_training

  def create
    participant = Participant.staff.find(params[:participant_id])
    _record, status = TrainingAttendance.register(training: @training, participant: participant,
                                                  recorded_by: Current.user&.participant, source: :manual)

    notice = status == :already ? "#{participant.full_name} ya estaba marcado." : "#{participant.full_name} quedó marcado."
    redirect_back fallback_location: agenda_training_path(@training), notice: notice
  end

  def destroy
    attendance = @training.attendances.find(params[:id])
    name = attendance.participant.full_name
    attendance.destroy

    redirect_back fallback_location: agenda_training_path(@training),
                  notice: "Se quitó la asistencia de #{name}."
  end

  private
    def set_training
      @training = Training.find(params[:training_id])
    end
end
