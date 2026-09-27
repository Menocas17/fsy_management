# El registro de llegadas del día del evento. Pensado para escanear sin parar y para aguantar
# que se caiga la señal: el dispositivo se lleva el padrón y encola lo que no pudo enviar.
class CheckinsController < ApplicationController
  before_action :require_checkin_access!

  def index
    @jovenes = Participant.joven.count
    @arrived = Checkin.count
    @recent = Checkin.recent.includes(participant: :company).limit(12)
  end

  # El padrón que el teléfono guarda para poder reconocer a quien escanea aunque no haya internet.
  def roster
    people = Participant.joven.includes(:company).order(:first_name, :last_name)
    arrived = Checkin.arrived_ids

    render json: {
      generated_at: Time.current.iso8601,
      people: people.map { |person| roster_entry(person, arrived) }
    }
  end

  # Acepta un escaneo o el montón que quedó pendiente sin señal; repetir un envío no duplica nada.
  def create
    results = Array(params[:checkins]).map { |scan| register(scan) }

    render json: { results: results, arrived: Checkin.count, total: Participant.joven.count }
  end

  private
    def register(scan)
      participant = Participant.joven.includes(:company).find_by(id: scan[:participant_id])
      return { client_token: scan[:client_token], status: "unknown" } if participant.nil?

      checkin, status = Checkin.register(
        participant: participant,
        recorded_by: Current.user&.participant,
        recorded_at: parse_time(scan[:recorded_at]),
        source: scan[:source] == "manual" ? :manual : :qr,
        client_token: scan[:client_token]
      )

      { client_token: scan[:client_token], status: status.to_s, participant: card(participant),
        recorded_at: checkin&.recorded_at&.iso8601 }
    end

    def card(participant)
      {
        id: participant.id,
        name: participant.full_name,
        company: participant.company&.name,
        room: participant.room.presence,
        care: participant.allergies.presence
      }
    end

    def roster_entry(person, arrived)
      card(person).merge(arrived: arrived.include?(person.id))
    end

    # La hora la pone el dispositivo cuando escanea, no cuando logra sincronizar; si viene rara, manda el servidor.
    def parse_time(value)
      time = Time.zone.parse(value.to_s)
      time && time <= Time.current && time > 2.days.ago ? time : Time.current
    rescue ArgumentError
      Time.current
    end
end
