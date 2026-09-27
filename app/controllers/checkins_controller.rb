
class CheckinsController < ApplicationController
  before_action :require_checkin_access!
  before_action :set_mode

  def index
    @trainings = Training.upcoming.to_a
    @expected = expected_scope.count
    @registered = registered_count
    @recent = recent_registrations
  end

  # El padrón que el teléfono guarda para reconocer a quien escanea aunque no haya internet.
  def roster
    people = expected_scope.includes(:company).order(:first_name, :last_name)
    already = registered_ids

    render json: {
      mode: @mode, generated_at: Time.current.iso8601,
      people: people.map { |person| card(person).merge(arrived: already.include?(person.id)) }
    }
  end

  # Acepta un escaneo o el montón que quedó pendiente sin señal; repetir un envío no duplica nada.
  def create
    results = Array(params[:checkins]).map { |scan| register(scan) }

    render json: { results: results, arrived: registered_count, total: expected_scope.count }
  end

  private
    # El modo llega como "llegada" o como el id de una capacitación.
    def set_mode
      @training = Training.find_by(id: params[:training_id]) if params[:training_id].present?
      @mode = @training ? "training" : "arrival"
    end

    def expected_scope
      @training ? Training.expected : Participant.joven
    end

    def registered_count
      @training ? @training.attendances.count : Checkin.count
    end

    def registered_ids
      @training ? @training.attendances.pluck(:participant_id).to_set : Checkin.arrived_ids
    end

    def recent_registrations
      if @training
        @training.attendances.recent.includes(participant: :company).limit(12)
      else
        Checkin.recent.includes(participant: :company).limit(12)
      end
    end

    def register(scan)
      participant = expected_scope.includes(:company).find_by(id: scan[:participant_id])
      return { client_token: scan[:client_token], status: "unknown" } if participant.nil?

      record, status = record_for(participant, scan)

      { client_token: scan[:client_token], status: status.to_s, participant: card(participant),
        recorded_at: record&.recorded_at&.iso8601 }
    end

    def record_for(participant, scan)
      attributes = {
        participant: participant,
        recorded_by: Current.user&.participant,
        recorded_at: parse_time(scan[:recorded_at]),
        source: scan[:source] == "manual" ? :manual : :qr,
        client_token: scan[:client_token]
      }

      if @training
        TrainingAttendance.register(training: @training, **attributes)
      else
        Checkin.register(**attributes)
      end
    end

    def card(participant)
      {
        id: participant.id,
        name: participant.full_name,
        company: participant.company&.name || participant.logistics_area&.name || participant.role_label,
        room: participant.room.presence,
        care: participant.allergies.presence
      }
    end

    # La hora la pone el dispositivo cuando escanea, no cuando logra sincronizar; si viene rara, manda el servidor.
    def parse_time(value)
      time = Time.zone.parse(value.to_s)
      time && time <= Time.current && time > 2.days.ago ? time : Time.current
    rescue ArgumentError
      Time.current
    end
end
