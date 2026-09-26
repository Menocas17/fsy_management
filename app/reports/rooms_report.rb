# Cuartos con sus ocupantes, para pegar en la recepción del hospedaje.
class RoomsReport < ApplicationReport
  filename_stem "cuartos"

  private
    def title
      "Distribución de cuartos"
    end

    def subtitle
      "#{rooms.size} #{rooms.size == 1 ? 'cuarto' : 'cuartos'} · #{rooms.sum { |_, people| people.size }} personas"
    end

    def build(pdf)
      rows = rooms.map do |room, people|
        [
          room,
          people.size.to_s,
          people.map(&:full_name).join(", "),
          people.filter_map { |person| person.company&.name }.uniq.join(", ").presence || "—"
        ]
      end

      table(pdf, [ "Cuarto", "Personas", "Ocupantes", "Compañía" ], rows,
            widths: { 0 => 70, 1 => 55, 3 => 120 }, align: { 1 => :center })

      unassigned = Participant.where(room: [ nil, "" ]).order(:first_name, :last_name).to_a
      return if unassigned.empty?

      pdf.move_down 6
      section_title(pdf, "Sin cuarto asignado · #{unassigned.size}")
      table(pdf, [ "Nombre", "Rol", "Compañía" ],
            unassigned.map { |person| [ person.full_name, person.role_label, blank(person.company&.name) ] },
            widths: { 1 => 110, 2 => 150 })
    end

    # Los cuartos se ordenan como números cuando lo son ("2" antes que "10"), y alfabéticamente si no.
    def rooms
      @rooms ||= Participant.includes(:company).where.not(room: [ nil, "" ])
                            .order(:first_name, :last_name)
                            .group_by(&:room)
                            .sort_by { |room, _| [ room.to_i, room ] }
    end
end
