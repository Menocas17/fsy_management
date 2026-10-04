module InfirmaryHelper
  REASON_ICONS = { "fiebre" => "thermometer", "malestar" => "activity", "lesion" => "bandage", "alergia" => "shield-plus", "otro" => "stethoscope" }.freeze
  DISPOSITION_STYLES = { "regreso" => [ "undo-2", :green ], "casa" => [ "house", :amber ], "hospital" => [ "ambulance", :rose ] }.freeze

  # «12 min», «2 h 15»: lo que lleva un joven en enfermería. elapsed_controller.js lo repite cada minuto con
  # la misma forma, para que un tablero abierto toda la tarde no se quede atrás.
  def infirmary_elapsed(since, now: Time.current)
    minutes = [ ((now - since) / 60).floor, 0 ].max
    return "#{minutes} min" if minutes < 60

    format("%d h %02d", minutes / 60, minutes % 60)
  end

  def infirmary_reason_icon(visit)
    REASON_ICONS.fetch(visit.reason.to_s, "stethoscope")
  end

  def infirmary_disposition_chip(visit)
    icon_name, tone = DISPOSITION_STYLES.fetch(visit.disposition.to_s, [ "check", :neutral ])
    render ChipComponent.new(label: visit.disposition_label || "Alta", tone: tone, icon: icon_name, data: { disposition: visit.disposition })
  end

  # Lo médico de su ficha que enfermería tiene que ver antes de darle algo: alergias y medicinas, si dicen algo.
  def infirmary_medical_flags(participant)
    { allergies: participant.allergies, medicines: participant.medicines }.select { |_, value| medical_note?(value) }
  end

  # La hora, y el día si no fue hoy: «11:43» o «lun 12 · 21:10».
  def infirmary_time(time)
    return time.strftime("%H:%M") if time.to_date == Time.zone.today

    "#{SpanishDates.abbr(time.to_date)} #{time.day} · #{time.strftime("%H:%M")}"
  end
end
