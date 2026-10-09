# Los cumpleañeros del mes del FSY (enero) y, aparte, los que cumplen durante la semana del evento, para
# celebrarlos ese día. Todos (jóvenes y staff) o solo los jóvenes, con la edad que cumplen.
class BirthdaysReport < ApplicationReport
  filename_stem "cumpleaneros"

  SCOPES = { "todos" => "Jóvenes y staff", "jovenes" => "Solo jóvenes" }.freeze

  def initialize(scope: "todos", start_on: Rails.configuration.x.event_start_on, end_on: Rails.configuration.x.event_end_on)
    @scope = SCOPES.key?(scope.to_s) ? scope.to_s : "todos"
    @start_on = start_on
    @end_on = end_on
  end

  def filename
    [ self.class.filename_stem, (@scope unless @scope == "todos"), Date.current.strftime("%Y-%m-%d") ].compact.join("-") + ".pdf"
  end

  private
    def title
      "Cumpleañeros de #{SpanishDates.month(@start_on)}"
    end

    def subtitle
      "#{SCOPES.fetch(@scope)} · #{month_people.size} en #{SpanishDates.month(@start_on)} · #{week_people.size} durante el FSY"
    end

    def build(pdf)
      section_title(pdf, "Durante el FSY · #{SpanishDates.range(@start_on, @end_on)}")
      table(pdf, headers, rows(week_people, with_weekday: true), widths: widths, align: { 4 => :center })

      pdf.move_down 8
      section_title(pdf, "Todo #{SpanishDates.month(@start_on)} · #{month_people.size}")
      table(pdf, headers, rows(month_people), widths: widths, align: { 4 => :center })
    end

    def headers
      [ "Día", "Nombre", "Rol", "Compañía o área", "Cumple" ]
    end

    def widths
      { 0 => 95, 2 => 85, 3 => 120, 4 => 50 }
    end

    def rows(people, with_weekday: false)
      people.map do |person, birthday|
        day = with_weekday ? SpanishDates.long(birthday) : "#{birthday.day} de #{SpanishDates.month(birthday)}"
        [ day, person.full_name, person.role_label, blank(group_of(person)),
          "#{birthday.year - person.birth_date.year} años" ]
      end
    end

    # Su compañía; el auxiliar, la compañía auxiliar que cuida; logística, su área.
    def group_of(person)
      person.company&.name || person.auxiliar_companies.first&.name || person.logistics_area&.name
    end

    # [persona, su cumpleaños en el año del evento], del día 1 al último del mes.
    def month_people
      people = @scope == "jovenes" ? Participant.jovenes : Participant.all
      @month_people ||= people.includes(:company, :logistics_area, :auxiliar_companies)
                                   .where("EXTRACT(MONTH FROM birth_date) = ?", @start_on.month)
                                   .map { |person| [ person, birthday_in(person, @start_on.year) ] }
                                   .sort_by { |person, birthday| [ birthday, person.full_name ] }
    end

    def week_people
      @week_people ||= month_people.select { |_, birthday| birthday.between?(@start_on, @end_on) }
    end

    # El 29 de febrero, en un año que no es bisiesto, se celebra el 28.
    def birthday_in(person, year)
      Date.new(year, person.birth_date.month, person.birth_date.day)
    rescue Date::Error
      Date.new(year, person.birth_date.month, 28)
    end
end
