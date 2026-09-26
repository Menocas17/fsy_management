# Lista imprimible de participantes: todos, solo mujeres, solo hombres o solo staff.
class ParticipantsReport < ApplicationReport
  self.page_layout = :landscape

  SCOPES = {
    "todos"   => { title: "Lista de participantes", stem: "participantes" },
    "mujeres" => { title: "Lista de participantes · Mujeres", stem: "participantes-mujeres" },
    "hombres" => { title: "Lista de participantes · Hombres", stem: "participantes-hombres" },
    "staff"   => { title: "Lista del staff", stem: "staff" }
  }.freeze

  def self.scope?(name)
    SCOPES.key?(name.to_s)
  end

  def initialize(scope: "todos")
    @scope = SCOPES.key?(scope.to_s) ? scope.to_s : "todos"
  end

  def filename
    "#{SCOPES.fetch(@scope)[:stem]}-#{Date.current.strftime('%Y-%m-%d')}.pdf"
  end

  private
    def title
      SCOPES.fetch(@scope)[:title]
    end

    def subtitle
      "#{participants.size} #{participants.size == 1 ? 'registro' : 'registros'}"
    end

    def build(pdf)
      by_company = participants.group_by { |participant| participant.company }
                               .sort_by { |company, _| [ company&.number || Float::INFINITY, company&.name.to_s ] }

      by_company.each_with_index do |(company, people), index|
        pdf.start_new_page if index.positive? && pdf.cursor < 90
        section_title(pdf, company&.name || "Sin compañía asignada")
        table(pdf, HEADERS, people.map { |person| row_for(person) },
              widths: COLUMN_WIDTHS, align: { 1 => :center, 6 => :center })
      end
    end

    HEADERS = [ "Nombre", "Edad", "Género", "Rol", "Estaca", "Barrio", "Camisa", "Cuarto", "Teléfono" ].freeze
    COLUMN_WIDTHS = { 0 => 170, 1 => 36, 2 => 52, 3 => 74, 5 => 95, 6 => 44, 7 => 52 }.freeze

    def row_for(participant)
      [
        participant.full_name,
        participant.age.to_s,
        Participant::GENDER_LABELS.fetch(participant.gender, "—"),
        participant.role_label,
        blank(participant.stake&.titleize),
        blank(participant.ward&.titleize),
        blank(participant.shirt_number&.upcase),
        blank(participant.room),
        blank(participant.phone_number)
      ]
    end

    def participants
      @participants ||= begin
        relation = Participant.includes(:company).order(:first_name, :last_name, :id)
        case @scope
        when "mujeres" then relation.jovenes.where(gender: "M")
        when "hombres" then relation.jovenes.where(gender: "H")
        when "staff"   then relation.staff
        else relation.jovenes
        end.to_a
      end
    end
end
