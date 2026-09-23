module AgendaHelper
  def spanish_date(date)
    SpanishDates.long(date)
  end

  def spanish_day_abbr(date)
    SpanishDates.abbr(date)
  end

  def spanish_range(first_day, last_day)
    SpanishDates.range(first_day, last_day)
  end
end
