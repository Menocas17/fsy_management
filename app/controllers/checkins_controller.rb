
class CheckinsController < ApplicationController
  # Por qué se anula un registro hecho en la fila (ver #void).
  VOID_REASONS = { "otra_persona" => "No era la persona", "escaneo_incorrecto" => "Escaneo incorrecto", "otro" => "Otro" }.freeze
  # Los últimos que se ven bajo el escáner: más empujaría «Finalizar registro» hasta el fondo; el resto, en «Ver todos».
  RECENT_LIMIT = 10

  before_action :require_checkin_access!
  before_action :require_scan_manager!, only: %i[finish reopen]
  before_action :set_mode, except: %i[finish reopen]
  helper_method :recent_stream

  def index
    # Sin nada elegido se entra directo al registro activo, si es una capacitación.
    if @training.nil? && (active = ScanWindow.active_training)
      return redirect_to checkins_path(training_id: active.id, return_to: helpers.safe_return_to(nil))
    end

    @expected = expected_scope.count
    @registered = registered_count
    @recent = registrations.limit(RECENT_LIMIT)
  end

  # Todos los registrados, del último al primero (la página de Registro muestra solo los RECENT_LIMIT últimos).
  def registered
    @pagy, @records = pagy(registrations, limit: 25)
  end

  # El padrón que el teléfono guarda para reconocer a quien escanea aunque no haya internet.
  def roster
    return render json: { error: @window.closed_reason }, status: :forbidden unless @window.open?

    people = expected_scope.includes(:company, :logistics_area).order(:first_name, :last_name)
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

  # «Finalizar registro»: los jóvenes ya pueden ver su compañía (CompanyReveal) y les llega un aviso a todos.
  # El escáner sigue abierto para quien llegue tarde.
  def finish
    unless CompanyReveal.open_to_jovenes?
      CompanyReveal.open_to_jovenes!
      record_audit!(category: :registro, action: "registro_finished", target: nil,
                    summary: "Finalizó el registro de llegadas: los jóvenes ya ven su compañía")
      sender = Current.user.participant
      CompanyReveal.announce_to_jovenes!(sender: sender, sender_name: sender&.full_name || "Logística")
    end
    redirect_to checkins_path, notice: "Registro finalizado: los jóvenes ya ven su compañía y les llegó el aviso."
  end

  # Deshacerlo (se finalizó antes de tiempo): los jóvenes vuelven a ver «Próximamente». No les avisa nada.
  def reopen
    if CompanyReveal.open_to_jovenes?
      CompanyReveal.close_to_jovenes!
      record_audit!(category: :registro, action: "registro_reopened", target: nil,
                    summary: "Reabrió el registro de llegadas: los jóvenes vuelven a ver «Próximamente» en su compañía")
    end
    redirect_to checkins_path, notice: "Registro reabierto: los jóvenes vuelven a ver «Próximamente»."
  end

  private
    def require_scan_manager!
      redirect_to checkins_path, alert: "Solo el director de logística o dirección finalizan el registro." unless Current.user.scan_manager?
    end

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

    # «Últimos registrados» se llena solo: lo que entra (de este teléfono o de otro que registra lo mismo) sube a
    # la lista de quien tenga abierta la página, y lo anulado se va. Cada registro, su propia transmisión.
    def recent_stream
      @training ? [ @training, :checkins ] : :arrival_checkins
    end

    def broadcast_recent(record)
      Turbo::StreamsChannel.broadcast_prepend_later_to(recent_stream, target: "recent_checkins",
                                                       partial: "checkins/record", locals: { record: record, voidable: true })
    end

    def registrations
      (@training ? @training.attendances : Checkin).recent.includes(participant: :company)
    end

    def register(scan)
      # Se juzga por la hora del escaneo: lo que se tomó sin señal mientras estaba activo entra aunque llegue después.
      return { client_token: scan[:client_token], status: "closed" } unless @window.open?(parse_time(scan[:recorded_at]))

      # Normalmente llega el id (lo resuelve el teléfono con su padrón); por si acaso, también el código corto.
      participant = expected_scope.includes(:company).find_by_badge(scan[:participant_id])
      return { client_token: scan[:client_token], status: "unknown" } if participant.nil?

      record, status = record_for(participant, scan)
      broadcast_recent(record) if status == :registered

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
      Turbo::StreamsChannel.broadcast_remove_to(recent_stream, target: helpers.dom_id(record))
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
        stake: participant.stake_name,
        gender: Participant::GENDER_LABELS[participant.gender],
        # Desde la ficha, «Volver» regresa a este mismo registro (llegada o la capacitación elegida), que a su
        # vez sigue sabiendo a dónde volver (return_to).
        url: participant_path(participant, from: "escaner",
                              return_to: checkins_path(training_id: @training&.id, return_to: helpers.safe_return_to(nil)))
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
