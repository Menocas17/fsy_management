# The es locale carries no date formats, so dates are spelled out here.
# Shared by the agenda views (through AgendaHelper) and by models that write alert text.
module SpanishDates
  DAY_NAMES = %w[domingo lunes martes miércoles jueves viernes sábado].freeze
  DAY_ABBR = %w[Dom Lun Mar Mié Jue Vie Sáb].freeze
  MONTH_NAMES = %w[enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre].freeze

  module_function

  def long(date)
    "#{DAY_NAMES[date.wday].capitalize} #{date.day} de #{MONTH_NAMES[date.month - 1]}"
  end

  def abbr(date)
    DAY_ABBR[date.wday]
  end

  def month(date)
    MONTH_NAMES[date.month - 1]
  end

  # "23 de septiembre, 9:12" — el sello de cada movimiento del inventario.
  def short_with_time(time)
    zoned = time.in_time_zone
    "#{zoned.day} de #{MONTH_NAMES[zoned.month - 1]}, #{zoned.strftime('%H:%M')}"
  end

  def range(first_day, last_day)
    if first_day.month == last_day.month
      "#{first_day.day} – #{last_day.day} de #{month(first_day)}, #{last_day.year}"
    else
      "#{first_day.day} de #{month(first_day)} – #{last_day.day} de #{month(last_day)}, #{last_day.year}"
    end
  end
end
