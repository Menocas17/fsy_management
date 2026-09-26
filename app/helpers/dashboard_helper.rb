module DashboardHelper
  def event_start_at
    Time.zone.local(Rails.configuration.x.event_start_on.year,
                    Rails.configuration.x.event_start_on.month,
                    Rails.configuration.x.event_start_on.day,
                    Rails.configuration.x.event_start_hour)
  end

  # Days, hours and minutes left before the event opens; all zeros once it has started.
  def event_countdown(now = Time.current)
    remaining = [ (event_start_at - now).to_i, 0 ].max

    {
      days: remaining / 86_400,
      hours: (remaining % 86_400) / 3600,
      minutes: (remaining % 3600) / 60,
      seconds: remaining % 60,
      started: remaining.zero?
    }
  end

  # Shortcut for whoever can't register participants: the company they belong to. A joven goes to their own
  # company, a consejero to the company of jóvenes they staff, an auxiliar to the auxiliar company that groups
  # their counselors. Logística and registradores have no company, so they get no shortcut.
  def my_company_link
    participant = Current.user&.participant
    return nil if participant.nil?

    case participant.rol.to_s
    when "auxiliar"
      auxiliar_company = participant.auxiliar_scope[:auxiliar_company]
      auxiliar_company && auxiliar_company_path(auxiliar_company)
    when "consejero"
      company = participant.counselor_scope.first
      company && company_path(company)
    else
      participant.company && company_path(participant.company)
    end
  end

  def next_trainings(limit = 2)
    Array(Rails.configuration.x.training_dates).select { |date| date >= Date.current }.sort.first(limit)
  end

  def event_in_progress?
    Date.current.between?(Rails.configuration.x.event_start_on, Rails.configuration.x.event_end_on)
  end

  # Días que faltan, contados por fecha: hoy es 0 y ayer ya no se muestra.
  def days_until(date)
    (date - Date.current).to_i
  end

  def countdown_label(days)
    case days
    when ..-1 then nil
    when 0 then "Es hoy"
    when 1 then "Falta 1 día"
    else "Faltan #{days} días"
    end
  end

  def event_start_label
    "#{SpanishDates.long(Rails.configuration.x.event_start_on)} de #{Rails.configuration.x.event_start_on.year}"
  end
end
