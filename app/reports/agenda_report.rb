# La agenda completa del evento, un bloque por día.
class AgendaReport < ApplicationReport
  filename_stem "agenda"

  private
    def title
      "Agenda del evento"
    end

    def subtitle
      "#{activities.size} #{activities.size == 1 ? 'actividad' : 'actividades'}"
    end

    def build(pdf)
      Activity.event_days.each_with_index do |day, index|
        of_the_day = activities.select { |activity| activity.starts_at.to_date == day }
        pdf.start_new_page if index.positive? && pdf.cursor < 110

        section_title(pdf, SpanishDates.long(day).capitalize)
        table(pdf, [ "Hora", "Actividad", "Lugar", "Categoría", "Dirigida a" ],
              of_the_day.map { |activity| row_for(activity) },
              widths: { 0 => 78, 2 => 105, 3 => 85 })
      end
    end

    def row_for(activity)
      [
        activity.time_range,
        activity.title,
        blank(activity.location),
        activity.category.to_s.titleize,
        activity.audience_label
      ]
    end

    def activities
      @activities ||= Activity.order(:starts_at).to_a
    end
end
