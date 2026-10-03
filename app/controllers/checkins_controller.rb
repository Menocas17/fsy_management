
class CheckinsController < ApplicationController
  # Por qué se anula un registro hecho en la fila (ver #void).
  VOID_REASONS = { "otra_persona" => "No era la persona", "escaneo_incorrecto" => "Escaneo incorrecto", "otro" => "Otro" }.freeze

  before_action :require_checkin_access!
  before_action :set_mode

  def index
    @trainings = Training.chronological.select { |training| training.scan_window.open? }
    @arrival_open = ScanWindow.arrival.open?

    # Sin nada elegido y con la llegada cerrada, se entra directo al registro que sí está abierto hoy.
    if @training.nil? && !@arrival_open && @trainings.any?
      return redirect_to checkins_path(training_id: @trainings.first.id)
    end

    @expected = expected_scope.count
    @registered = registered_count
    @recent = recent_registrations
  end

  # El padrón que el teléfono guarda para reconocer a quien escanea aunque no haya internet.
  def roster
    return render json: { error: @window.closed_reason }, status: :forbidden unless @window.open?

    people = expected_scope.includes(:company).order(:first_name, :last_name)
    already = registered_ids

    render json: {
      mode: @mode, generated_at: Time.current.iso8601,
      people: people.map { |person| card(person).merge(arrived: already.include?(person.id)) }
    }
  end

  # Acepta un escaneo o el montón que quedó pendiente sin señal; repetir un envío no duplica nada. En la misma
  # cola van las anulaciones (kind: "void"), en orden: un escaneo y su anulación hechos sin señal llegan juntos.
  def create
    results = Array(params[:checkins]).map { |scan| scan[:kind] == "void" ? void(scan) : register(scan) }

    render json: { results: results, arrived: registered_count, total: expected_scope.count }
  end

  private
    # El modo llega como "llegada" o como el id de una capacitación.
    def set_mode
      @training = Training.find_by(id: params[:training_id]) if params[:training_id].present?
      @mode = @training ? "training" : "arrival"
      @window = ScanWindow.for(@training)
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
      # Se juzga por la hora del escaneo: lo que se tomó sin señal el día que tocaba entra aunque llegue después.
      return { client_token: scan[:client_token], status: "closed" } unless @window.open?(parse_time(scan[:recorded_at]))

      # Normalmente llega el id (lo resuelve el teléfono con su padrón); por si acaso, también el código corto.
      participant = expected_scope.includes(:company).find_by_badge(scan[:participant_id])
      return { client_token: scan[:client_token], status: "unknown" } if participant.nil?

      record, status = record_for(participant, scan)

      { client_token: scan[:client_token], status: status.to_s, participant: card(participant),
        recorded_at: record&.recorded_at&.iso8601 }
    end

    # Anular lo que registró un escaneo (llegó alguien con el gafete de otra persona, o se escaneó el que no
    # era): la persona vuelve a quedar sin llegar y queda constancia en el Historial con el motivo.
    # Solo se anula el registro que creó ese escaneo (su client_token) o el que se eligió en la lista
    # (record_id): si el escaneo encontró a la persona «ya registrada», no hay nada suyo que anular, y así
    # nunca se borra la llegada verdadera.
    def void(scan)
      reason = VOID_REASONS[scan[:reason].to_s]
      return { client_token: scan[:client_token], status: "invalid" } if reason.nil?

      records = @training ? @training.attendances : Checkin.all
      record = if scan[:record_id].present?
        records.find_by(id: scan[:record_id])
      elsif scan[:target_token].present?
        records.find_by(client_token: scan[:target_token])
      end
      return { client_token: scan[:client_token], status: "void_missing" } if record.nil?

      participant = record.participant
      detail = scan[:detail].to_s.squish.first(300).presence
      record.destroy!
      record_audit!(category: :registro, action: "voided", target: participant,
                    summary: "Anuló #{@training ? "la asistencia a #{@training.name}" : "la llegada"} de #{participant.full_name} " \
                             "(#{[ reason, detail ].compact.join(": ")})")

      { client_token: scan[:client_token], status: "voided", participant_id: participant.id }
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

    # Lo justo para confirmar a quién se escaneó. Sin datos médicos: el padrón queda guardado en el
    # dispositivo y se ve en una pantalla que mira la fila; eso vive en la ficha, a un toque.
    def card(participant)
      {
        id: participant.id,
        name: participant.full_name,
        code: participant.code,
        company: participant.company&.name || participant.logistics_area&.name || participant.role_label,
        stake: participant.stake&.titleize,
        gender: Participant::GENDER_LABELS[participant.gender],
        # Desde la ficha, «Volver» regresa a este mismo registro (llegada o la capacitación elegida).
        url: participant_path(participant, from: "escaner", return_to: checkins_path(training_id: @training&.id))
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
