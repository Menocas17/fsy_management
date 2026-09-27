# El resumen de capacitaciones, dentro de la agenda. Lo ve cualquiera del staff; marcar a mano queda
# para el mismo comité que registra llegadas.
class TrainingsController < ApplicationController
  before_action :set_training, only: [ :show ]

  def index
    @trainings = Training.chronological.to_a
    @staff = Participant.staff.includes(:company, :logistics_area).order(:first_name, :last_name)
    # Una sola consulta para toda la tabla: quién asistió a qué.
    @attended = TrainingAttendance.pluck(:training_id, :participant_id).group_by(&:first)
                                  .transform_values { |pairs| pairs.map(&:last).to_set }
    @by_role = (@trainings.select(&:past?).last || @trainings.first)&.role_breakdown || {}
  end

  def show
  end

  private
    def set_training
      @training = Training.find(params[:id])
    end
end
