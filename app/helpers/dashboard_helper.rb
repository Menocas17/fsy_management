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

  def event_start_label
    "#{SpanishDates.long(Rails.configuration.x.event_start_on)} de #{Rails.configuration.x.event_start_on.year}"
  end
end
