# El resumen de capacitaciones, dentro de la agenda. Lo ve cualquiera del staff; marcar a mano queda
# para el mismo comité que registra llegadas.
class TrainingsController < ApplicationController
  before_action :set_training, only: [ :show ]

  ROLE_GROUPS = {
    "Consejeros" => %w[consejero],
    "Auxiliares" => %w[auxiliar],
    "Logística" => %w[logistica director_logistica],
    "Dirección y coordinación" => %w[director coordinador registrador]
  }.freeze

  def index
    @trainings = Training.chronological.to_a
    @staff = Participant.staff.includes(:company, :logistics_area).order(:first_name, :last_name)
    # Una sola consulta para toda la tabla: quién asistió a qué.
    @attended = TrainingAttendance.pluck(:training_id, :participant_id).group_by(&:first)
                                  .transform_values { |pairs| pairs.map(&:last).to_set }
    @by_role = role_breakdown(@trainings.select(&:past?).last || @trainings.first)
  end

  def show
    @attendances = @training.attendances.recent.includes(participant: [ :company, :logistics_area ])
    @absentees = @training.absentees.includes(:company, :logistics_area)
    @by_role = role_breakdown(@training)
  end

  private
    def set_training
      @training = Training.find(params[:id])
    end

    # Cuántos de cada grupo asistieron: es lo que se mira para saber a quién hay que llamar.
    def role_breakdown(training)
      return {} if training.nil?

      present = training.attendances.joins(:participant).group("participants.rol").count
      expected = Participant.staff.group(:rol).count

      ROLE_GROUPS.filter_map do |label, roles|
        total = roles.sum { |role| expected[role].to_i }
        next if total.zero?

        [ label, { attended: roles.sum { |role| present[role].to_i }, expected: total } ]
      end.to_h
    end
end
