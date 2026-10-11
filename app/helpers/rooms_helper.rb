module RoomsHelper
  # Lo que muestra cada cuarto en la cuadrícula de pasillos: cuántos duermen ahí, de qué género (el color), para
  # quién es (el ícono), qué compañías y, en el tablero, lo que hay que revisar a mano.
  RoomTile = Struct.new(:room, :count, :gender, :kind, :companies, :spill, :issue, keyword_init: true)

  KIND_LABELS = {
    jovenes: "Jóvenes", consejeros: "Consejeros", coordinacion: "Coordinación y auxiliares",
    direccion: "Matrimonio director", logistica: "Matrimonio de logística", comite_logistica: "Comité de logística",
    staff: "Staff", mixto: "Jóvenes y adultos"
  }.freeze
  KIND_ICONS = { consejeros: "shield-user", coordinacion: "users-round", direccion: "heart-handshake",
                 logistica: "heart-handshake", comite_logistica: "boxes", staff: "user-check", mixto: "triangle-alert" }.freeze
  # Mujeres en rosa y hombres en azul, como en las gráficas (ChartsHelper::GENDER_CATEGORY); un cuarto de los
  # dos (un matrimonio), en índigo.
  TILE_TONES = {
    "M" => "bg-cat-rose/15 text-cat-rose-ink border-cat-rose/30",
    "H" => "bg-cat-blue/15 text-cat-blue-ink border-cat-blue/30",
    mixed: "bg-cat-indigo/15 text-cat-indigo-ink border-cat-indigo/30",
    empty: "bg-sunken text-ink-500 border-line-soft",
    off: "bg-canvas text-ink-300 border-dashed border-line"
  }.freeze
  GENDER_TONES = { "M" => :rose, "H" => :blue }.freeze

  # De lo guardado en las fichas: quién duerme hoy en cada cuarto.
  def room_tiles_from_occupants(rooms, occupants_by_room)
    rooms.to_h do |room|
      people = occupants_by_room.fetch(room.number, [])
      [ room.id, RoomTile.new(room: room, count: people.size, gender: single_gender(people), kind: room_kind(people),
                              companies: company_numbers(people), issue: room_issue(room, people)) ]
    end
  end

  # De la propuesta del ordenamiento (RoomPlanner::Plan), sin guardar.
  def room_tiles_from_plan(plan, rooms)
    rooms.to_h do |room|
      slot = plan.slot_for(room)
      tile = if slot
        RoomTile.new(room: room, count: slot.occupants.size, gender: slot.gender || single_gender(slot.occupants),
                     kind: slot.kind, companies: company_numbers(slot.occupants), spill: slot.spill)
      else
        RoomTile.new(room: room, count: 0)
      end
      [ room.id, tile ]
    end
  end

  def room_tile_classes(tile)
    tone = if tile.count.zero? then tile.room.purpose_fuera_de_uso? ? :off : :empty
    else tile.gender || :mixed
    end
    ring = " ring-2 ring-cat-amber-solid" if tile.issue || tile.spill
    "#{TILE_TONES.fetch(tone)}#{ring}"
  end

  def room_tile_icon(tile)
    return "triangle-alert" if tile.issue || tile.spill
    return "ban" if tile.room.purpose_fuera_de_uso? && tile.count.zero?

    KIND_ICONS[tile.kind]
  end

  # Lo que dice el cuarto al pasarle el ratón y a los lectores de pantalla.
  def room_tile_title(tile)
    parts = [ "Cuarto #{tile.room.number}", "#{tile.count} de #{tile.room.capacity} camas" ]
    parts << (tile.gender ? Hallway::GENDER_LABELS[tile.gender] : "Hombres y mujeres") if tile.count.positive?
    parts << KIND_LABELS[tile.kind] if tile.kind && tile.kind != :jovenes
    parts << "Compañía #{tile.companies.join(" y ")}" if tile.companies.present?
    parts << tile.room.purpose_label unless tile.room.purpose_auto?
    parts << "En un pasillo del otro género" if tile.spill
    parts << tile.issue if tile.issue
    parts.join(" · ")
  end

  # De quién es el pasillo según quién duerme en él: Mujeres, Hombres o, si hay de los dos, Mixto.
  def hallway_gender(hallway, tiles)
    genders = hallway.rooms.filter_map { |room| tiles[room.id] }
                     .select { |tile| tile.count.positive? && %i[jovenes consejeros].include?(tile.kind) }
                     .map(&:gender).uniq
    return hallway.gender if genders.empty?

    genders.size == 1 ? genders.first : :mixed
  end

  def hallway_gender_chip(gender)
    case gender
    when "M", "H" then render(ChipComponent.new(label: Hallway::GENDER_LABELS[gender], tone: GENDER_TONES[gender]))
    when :mixed then render(ChipComponent.new(label: "Mixto", tone: :amber, icon: "triangle-alert"))
    else render(ChipComponent.new(label: "Libre"))
    end
  end

  private
    def single_gender(people)
      genders = people.map(&:gender).uniq
      genders.first if genders.size == 1
    end

    def company_numbers(people)
      people.select(&:joven?).filter_map { |person| person.company&.number }.uniq.sort
    end

    def room_kind(people)
      return if people.empty?

      roles = people.map(&:rol).uniq
      return :jovenes if roles == [ "joven" ]
      return :mixto if roles.include?("joven")
      return :consejeros if roles == [ "consejero" ]
      return :direccion if roles == [ "director" ]
      return :logistica if roles == [ "director_logistica" ]
      return :coordinacion if (roles - RoomPlanner::COORDINATION_ROLES).empty?
      return :comite_logistica if (roles - RoomPlanner::LOGISTICS_ROLES).empty?

      :staff
    end

    # Lo que las reglas no permiten y quedó así (casi siempre por un cambio a mano en una ficha).
    def room_issue(room, people)
      jovenes = people.select(&:joven?)
      return "Jóvenes con adultos" if jovenes.any? && jovenes.size < people.size
      return "Un joven solo" if jovenes.size == 1
      return "Hombres y mujeres" if jovenes.map(&:gender).uniq.size > 1
      return "Más personas que camas" if people.size > room.capacity

      "Fuera de uso, con gente" if room.purpose_fuera_de_uso? && people.any?
    end
end
