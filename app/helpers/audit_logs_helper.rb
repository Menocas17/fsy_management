module AuditLogsHelper
  # El nombre de lo afectado, enlazado si todavía existe (lo borrado queda como texto).
  def audit_target(log, targets, **options)
    name = log.target_name.presence
    return tag.span("—", class: "text-ink-300") if name.nil?

    record = targets[[ log.target_type, log.target_id ]]
    path = record && audit_target_path(record)
    return tag.span(name, **options) if path.nil?

    link_to name, path, **options, class: [ options[:class], "underline decoration-line underline-offset-2 hover:text-primary-700 hover:decoration-primary-300 dark:hover:text-primary-300" ].compact.join(" "),
                        data: { turbo_frame: "_top" }
  end

  def audit_target_path(record)
    case record
    when Activity then agenda_path(date: record.day, activity_id: record.id)
    else polymorphic_path(record)
    end
  rescue NoMethodError, ActionController::UrlGenerationError
    nil
  end

  # «Hoy · 14:05», «Ayer · 09:12» o la fecha, para leer el historial de un vistazo.
  def audit_time(log, year: false)
    time = log.created_at.in_time_zone
    day = if time.to_date == Time.zone.today then "Hoy"
    elsif time.to_date == Time.zone.yesterday then "Ayer"
    else time.strftime(year ? "%d/%m/%Y" : "%d/%m")
    end
    "#{day} · #{time.strftime("%H:%M")}"
  end
end
