# El ordenamiento de cuartos: arma una propuesta sin guardar nada (RoomPlan la aplica). Las reglas:
#
# - Mujeres primero, después hombres, cada quien en sus pasillos (Hallway#gender, o los decide el ordenamiento
#   en el orden del hotel: los primeros para mujeres hasta que quepan, los siguientes para hombres).
# - Cada pasillo con jóvenes lleva un cuarto de consejeras (o consejeros) en su inicio, y un pasillo largo otro
#   al final. Jóvenes solo con jóvenes: nunca un adulto en su cuarto, y nunca un joven solo.
# - Las jóvenes de una misma compañía van juntas en cuartos seguidos; se mezclan dos compañías en un cuarto
#   solo cuando no sobran camas para evitarlo. Cada cuarto se llena hasta su capacidad.
# - Cada consejera duerme en el cuarto de staff del pasillo donde está la mayoría de su compañía.
# - Si los hombres no caben en sus pasillos, toman los últimos cuartos libres de un pasillo de mujeres (y al
#   revés): se avisa en la propuesta, porque es lo que más se intenta evitar.
# - Aparte: el matrimonio director y el de logística, cada uno en su cuarto, y coordinación con los auxiliares de
#   su mismo género. Van a los cuartos apartados para ellos (Room#purpose) o, si no hay, a uno libre.
# - El comité de logística puede dormir con otros adultos de su género: primero ocupa sus cuartos apartados, después
#   las camas libres de los cuartos de consejeros y de coordinación, y lo que falte, cuartos propios.
# - Entra todo el mundo: lo que diga hoy cada ficha (aunque sea un cuarto escrito a mano) se reemplaza.
#
# «Reordenar» es otra semilla: cambia el orden de las compañías y de cada quien dentro de ellas. Cada semilla
# prueba TRIALS órdenes y se queda con el mejor (Plan#score); la misma semilla da siempre la misma propuesta.
class RoomPlanner
  TRIALS = 12
  # Un pasillo con menos cuartos que esto (C3, D5) no lleva cuarto de staff propio: es un anexo del anterior.
  STAFF_ROOM_FROM = 3
  GENDERS = %w[M H].freeze
  COUNSELOR_ROLES = %w[consejero].freeze
  COORDINATION_ROLES = %w[coordinador auxiliar].freeze
  LOGISTICS_ROLES = %w[logistica].freeze
  COUPLES = { direccion: "director", logistica: "director_logistica" }.freeze
  # El ordenamiento acomoda a todos los roles, sin excepción.
  PLANNED_ROLES = Participant.rols.keys.freeze

  # Un cuarto de la propuesta. kind: :jovenes, :consejeros, :coordinacion, :direccion o :logistica.
  Slot = Struct.new(:room, :hallway, :kind, :gender, :occupants, :spill, keyword_init: true) do
    def free = room.capacity - occupants.size
    def companies = occupants.map(&:company_id).uniq
    def mixed? = kind == :jovenes && companies.size > 1
    def lone? = kind == :jovenes && occupants.size == 1
  end

  class Plan
    attr_reader :seed, :slots, :unplaced, :warnings, :arrived_only

    def initialize(seed:, slots:, unplaced:, warnings:, arrived_only:)
      @seed = seed
      @slots = slots
      @unplaced = unplaced
      @warnings = warnings
      @arrived_only = arrived_only
    end

    # El número de cuarto de cada persona ubicada.
    def assignments
      @assignments ||= slots.values.each_with_object({}) do |slot, map|
        slot.occupants.each { |person| map[person.id] = slot.room.number }
      end
    end

    def slot_for(room) = slots[room.id]
    def placed_count = assignments.size
    def rooms_used = slots.size
    def mixed_rooms = slots.values.count(&:mixed?)
    def lone_rooms = slots.values.count(&:lone?)
    def spill_rooms = slots.values.count(&:spill)
    def jovenes_slots = slots.values.select { |slot| slot.kind == :jovenes }

    # Compañías cuyas jóvenes (o jóvenes) quedaron repartidas en más de un pasillo.
    def split_companies
      jovenes_slots.flat_map { |slot| slot.occupants.map { |person| [ person.company_id, slot.gender, slot.hallway.id ] } }
                   .uniq.group_by { |company_id, gender, _| [ company_id, gender ] }
                   .count { |(company_id, _), halls| company_id && halls.size > 1 }
    end

    # Guarda la propuesta en las fichas (participants.room). Quien no quedó ubicado (o, con «solo llegados»,
    # el joven que todavía no llegó) queda sin cuarto: no sobrevive ningún cuarto escrito a mano.
    # Devuelve cuántas fichas cambiaron.
    def apply!
      now = Time.current
      Participant.transaction do
        changed = Participant.where.not(id: assignments.keys).where.not(room: [ nil, "" ]).update_all(room: nil, updated_at: now)
        assignments.group_by(&:last).each do |number, pairs|
          changed += Participant.where(id: pairs.map(&:first)).where("room IS DISTINCT FROM ?", number)
                                .update_all(room: number, updated_at: now)
        end
        changed
      end
    end

    # Menos es mejor: lo prohibido pesa más que lo que se intenta evitar, y al final, usar menos cuartos.
    def score
      @score ||= unplaced.size * 10_000 + lone_rooms * 1_000 + spill_rooms * 100 + mixed_rooms * 10 +
                 split_companies * 4 + rooms_used
    end
  end

  # La gente que entra al ordenamiento: todos los jóvenes (o solo los que ya llegaron) y el staff que se acomoda.
  def self.people(arrived_only: false)
    jovenes = Participant.joven
    jovenes = jovenes.where(id: Checkin.select(:participant_id)) if arrived_only
    staff = Participant.where(rol: PLANNED_ROLES - [ "joven" ])
    jovenes.or(staff).where.not(gender: nil).includes(:company).order(:first_name, :last_name, :id).to_a
  end

  # Lo mismo que leyó el ordenamiento, resumido: si cambia entre la vista previa y aplicarla, se vuelve a mostrar.
  def self.fingerprint(arrived_only: false)
    people = self.people(arrived_only: arrived_only).map { |person| [ person.id, person.rol, person.gender, person.company_id ] }
    rooms = Room.order(:id).pluck(:id, :hallway_id, :capacity, :purpose, :position)
    halls = Hallway.order(:id).pluck(:id, :gender, :long, :position)
    Digest::SHA256.hexdigest([ people, rooms, halls ].to_json)[0, 16]
  end

  def initialize(seed: nil, arrived_only: false, hallways: nil, people: nil)
    @seed = seed&.to_i
    @arrived_only = arrived_only
    @hallways = hallways || Hallway.ordered.includes(:rooms).to_a
    @people = people || self.class.people(arrived_only: arrived_only)
  end

  def call
    random = Random.new(@seed || 0)
    attempts = Array.new(TRIALS) do |index|
      # La primera vez (sin semilla), el primer intento va en el orden natural: compañía 1, 2, 3…
      Attempt.new(hallways: @hallways, people: @people, random: Random.new(random.rand(2**31)),
                  shuffle: !(@seed.nil? && index.zero?)).run
    end
    best = attempts.min_by { |attempt| attempt[:plan_score] }
    Plan.new(seed: @seed, slots: best[:slots], unplaced: best[:unplaced], warnings: best[:warnings], arrived_only: @arrived_only)
  end

  # Un intento con un orden: reparte a todos y deja cuánto vale (plan_score).
  class Attempt
    def initialize(hallways:, people:, random:, shuffle:)
      @hallways = hallways
      @hall_by_id = hallways.index_by(&:id)
      @room_order = hallways.flat_map(&:rooms).each_with_index.to_h { |room, index| [ room.id, index ] }
      @people = people
      @by_gender = people.group_by { |person| [ person.joven? ? :joven : person.rol, person.gender ] }
      @random = random
      @shuffle = shuffle
      @slots = {}
      @unplaced = []
      @warnings = []
    end

    def run
      halls_by_gender = allocate_hallways
      GENDERS.each { |gender| plan_gender(gender, halls_by_gender) }
      plan_specials(halls_by_gender)
      plan = Plan.new(seed: nil, slots: @slots, unplaced: @unplaced, warnings: @warnings, arrived_only: false)
      { slots: @slots, unplaced: @unplaced, warnings: @warnings, plan_score: plan.score }
    end

    private
      def jovenes(gender) = @by_gender.fetch([ :joven, gender ], [])
      def counselors(gender) = COUNSELOR_ROLES.flat_map { |rol| @by_gender.fetch([ rol, gender ], []) }
      def taken?(room) = @slots.key?(room.id)

      # Los cuartos que el ordenamiento usa para jóvenes y consejeros: ni apartados ni fuera de uso.
      def general_rooms(hall) = (@general_rooms ||= {})[hall.id] ||= hall.rooms.select(&:purpose_auto?)

      def shuffled(list)
        @shuffle ? list.shuffle(random: @random) : list
      end

      # Los pasillos de cada género: los fijos a mano, y los automáticos en orden del hotel, primero a las mujeres
      # hasta que les quepan sus jóvenes y después a los hombres. Los que sobran quedan de reserva (:spare).
      def allocate_hallways
        result = { "M" => [], "H" => [], spare: [] }
        @hallways.each { |hall| result[hall.gender] << hall if hall.gender }
        deficit = GENDERS.to_h { |gender| [ gender, jovenes(gender).size - result[gender].sum { |hall| youth_capacity(hall) } ] }
        @hallways.reject(&:gender).each do |hall|
          gender = GENDERS.find { |candidate| deficit[candidate].positive? }
          if gender
            result[gender] << hall
            deficit[gender] -= youth_capacity(hall)
          else
            result[:spare] << hall
          end
        end
        result
      end

      # Camas para jóvenes de un pasillo, sin su cuarto de staff (dos si es largo) ni los cuartos de una cama.
      def youth_capacity(hall)
        rooms = general_rooms(hall).reject { |room| taken?(room) }
        staff = rooms.size >= STAFF_ROOM_FROM ? [ rooms.first, (rooms.last if hall.long?) ].uniq.compact : []
        (rooms - staff).select { |room| room.capacity >= 2 }.sum(&:capacity)
      end

      def plan_gender(gender, halls_by_gender)
        youth = jovenes(gender)
        staff = counselors(gender)
        return if youth.empty? && staff.empty?

        halls = halls_by_gender[gender]
        # Si sus pasillos no alcanzan, se suman los de reserva antes de tocar los del otro género.
        halls += halls_by_gender[:spare].shift(1) while short?(halls, youth.size, staff.size) && halls_by_gender[:spare].any?
        halls_by_gender[gender] = halls
        active, staff_rooms, youth_rooms = choose_rooms(halls, youth.size, staff.size)

        spill = []
        missing = youth.size - youth_rooms.sum(&:capacity)
        if missing.positive?
          spill = spill_rooms(gender, halls_by_gender, missing)
          youth_rooms += spill
        end

        pour(youth, youth_rooms, gender, active, spill)
        fix_lone(gender)
        seat_counselors(staff, staff_rooms, gender, active)

        kinds = @slots.values.group_by(&:hallway).transform_values { |slots| slots.map(&:kind) }
        active.each do |hall|
          next if general_rooms(hall).size < STAFF_ROOM_FROM
          next if kinds.fetch(hall, []).include?(:consejeros) || !kinds.fetch(hall, []).include?(:jovenes)

          @warnings << "El pasillo #{hall.name} no tiene cuarto de #{gender == "M" ? "consejeras" : "consejeros"}: no alcanzan para todos los pasillos."
        end
      end

      def short?(halls, youth, staff)
        _, staff_rooms, youth_rooms = choose_rooms(halls, youth, staff)
        youth_rooms.sum(&:capacity) < youth || (staff.positive? && staff_rooms.empty?)
      end

      # Los pasillos que hacen falta (en orden) y, en ellos, los cuartos de staff y los de jóvenes.
      def choose_rooms(halls, youth, staff)
        active = []
        capacity = 0
        halls.each do |hall|
          break if active.any? && capacity >= youth

          active << hall
          capacity += youth_capacity(hall)
        end
        # Si los consejeros ocupan más cuartos de los previstos, hace falta un pasillo más.
        loop do
          staff_rooms, youth_rooms = split_rooms(active, staff)
          return [ active, staff_rooms, youth_rooms ] if youth_rooms.sum(&:capacity) >= youth || active.size >= halls.size

          active << halls[active.size]
        end
      end

      # Un cuarto de staff al inicio de cada pasillo, otro al final de los largos (mientras alcancen los
      # consejeros, uno por cuarto como mínimo), y más si no caben. El resto, para jóvenes.
      def split_rooms(active, staff)
        free = active.to_h { |hall| [ hall, general_rooms(hall).reject { |room| taken?(room) } ] }
        with_staff = active.select { |hall| general_rooms(hall).size >= STAFF_ROOM_FROM }
        candidates = with_staff.filter_map { |hall| free[hall].first } +
                     with_staff.select(&:long?).filter_map { |hall| free[hall].last if free[hall].size > 2 }
        staff_rooms = candidates.first(staff)
        extra = active.flat_map { |hall| free[hall] }.reject { |room| staff_rooms.include?(room) }
        staff_rooms << extra.shift while staff_rooms.sum(&:capacity) < staff && extra.any?
        youth_rooms = active.flat_map { |hall| free[hall] }.reject { |room| staff_rooms.include?(room) || room.capacity < 2 }
        [ staff_rooms, youth_rooms ]
      end

      # Los cuartos que faltan, tomados del final de los pasillos del otro género (los que estén libres).
      def spill_rooms(gender, halls_by_gender, missing)
        other = halls_by_gender[(GENDERS - [ gender ]).first]
        candidates = other.reverse.flat_map { |hall| general_rooms(hall).reverse }
                          .reject { |room| taken?(room) || room.capacity < 2 || other_gender_staff_room?(room) }
        rooms = []
        rooms << candidates.shift while rooms.sum(&:capacity) < missing && candidates.any?
        rooms.reverse
      end

      # El inicio de un pasillo queda para su cuarto de staff aunque el otro género todavía no se haya acomodado.
      def other_gender_staff_room?(room)
        hall = @hall_by_id[room.hallway_id]
        hall && general_rooms(hall).size >= STAFF_ROOM_FROM && general_rooms(hall).first == room
      end

      # Compañía por compañía, en cuartos seguidos. Si sobran camas, cada compañía va sola y repartida parejo, y
      # la siguiente empieza en un cuarto nuevo; si no, los cuartos se llenan y la siguiente completa el último.
      # Un sobrante de una persona nunca se deja: 5 en cuartos de 4 quedan 3 y 2.
      def pour(youth, rooms, gender, active, spill)
        groups = youth.group_by(&:company_id)
        order = groups.keys.sort_by { |id| [ id ? 0 : 1, company_number(groups[id]) ] }
        order = shuffled(order)
        slack = rooms.sum(&:capacity) - youth.size
        index = 0
        current = nil

        order.each do |company_id|
          remaining = shuffled(groups[company_id])
          while remaining.any?
            if index >= rooms.size
              remaining.each { |person| @unplaced << [ person, "No hay camas libres para #{gender == "M" ? "mujeres" : "hombres"}" ] }
              remaining = []
              break
            end
            room = rooms[index]
            current ||= open_slot(room, :jovenes, gender, spill.include?(room))
            take = [ current.free, remaining.size ].min
            rooms_needed = remaining.size.fdiv(room.capacity).ceil
            if current.occupants.empty? && rooms_needed > 1 && slack >= rooms_needed * room.capacity - remaining.size
              # Si alcanzan las camas para que la compañía vaya sola, se reparte parejo: 9 en cuartos de 4 son 3, 3 y 3.
              take = remaining.size.fdiv(rooms_needed).ceil
            elsif remaining.size - take == 1 && take >= 2 && slack >= 1 && current.occupants.size + take - 1 >= 2
              take -= 1
            end
            current.occupants.concat(remaining.shift(take))

            if current.free.zero? || remaining.any?
              slack -= current.free
              index += 1
              current = nil
            elsif current.occupants.size >= 2 && slack >= current.free
              # La compañía terminó con el cuarto a medias: si sobran camas, se cierra para no mezclar.
              slack -= current.free
              index += 1
              current = nil
            end
          end
        end
      end

      def company_number(group)
        group.first.company&.number || 0
      end

      def open_slot(room, kind, gender, spill = false)
        hall = @hall_by_id[room.hallway_id]
        @slots[room.id] = Slot.new(room: room, hallway: hall, kind: kind, gender: gender, occupants: [], spill: spill)
      end

      # Nadie duerme solo: pasa a un cuarto vecino con cama libre, o alguien de un cuarto de tres o más se le une.
      def fix_lone(gender)
        youth_slots = -> { @slots.values.select { |slot| slot.kind == :jovenes && slot.gender == gender } }
        youth_slots.call.select(&:lone?).each do |lone|
          next unless lone.lone?

          person = lone.occupants.first
          near = ->(slot) { [ slot.hallway == lone.hallway ? 0 : 1, slot.companies.include?(person.company_id) ? 0 : 1 ] }
          host = youth_slots.call.reject { |slot| slot.equal?(lone) || slot.free.zero? || slot.occupants.empty? }.min_by(&near)
          if host
            host.occupants << person
            @slots.delete(lone.room.id)
            next
          end

          donor = youth_slots.call.select { |slot| slot.occupants.size >= 3 }.min_by(&near)
          if donor
            moved = donor.occupants.find { |candidate| candidate.company_id == person.company_id } || donor.occupants.last
            donor.occupants.delete(moved)
            lone.occupants << moved
          else
            @warnings << "#{person.full_name} quedaría solo en el cuarto #{lone.room.number}: acomódalo a mano."
          end
        end
      end

      # Primero un consejero en cada cuarto de staff (el que tenga más jóvenes de su compañía en ese pasillo);
      # los demás, al cuarto de staff de su pasillo con cama libre, o a otro.
      def seat_counselors(staff, staff_rooms, gender, active)
        return if staff.empty?

        hall_counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }
        @slots.each_value do |slot|
          next unless slot.kind == :jovenes && slot.gender == gender

          slot.occupants.each { |person| hall_counts[person.company_id][slot.hallway.id] += 1 }
        end
        affinity = ->(person, room) { person.company_id ? hall_counts[person.company_id][room.hallway_id] : 0 }

        slots = staff_rooms.map { |room| open_slot(room, :consejeros, gender) }
        waiting = shuffled(staff)
        pairs = waiting.product(slots).sort_by { |person, slot| -affinity.(person, slot.room) }
        pairs.each do |person, slot|
          next if slot.occupants.any? || !waiting.include?(person)

          slot.occupants << person
          waiting.delete(person)
        end

        waiting.sort_by { |person| -(slots.map { |slot| affinity.(person, slot.room) }.max || 0) }.each do |person|
          slot = slots.select { |candidate| candidate.free.positive? }.max_by { |candidate| affinity.(person, candidate.room) }
          slot ||= begin
            spare = active.flat_map { |hall| general_rooms(hall) }.find { |room| !taken?(room) }
            open_slot(spare, :consejeros, gender).tap { |extra| slots << extra } if spare
          end
          if slot
            slot.occupants << person
          else
            @unplaced << [ person, "No hay cuarto de staff libre" ]
          end
        end
        slots.each { |slot| @slots.delete(slot.room.id) if slot.occupants.empty? }
      end

      # Los matrimonios y coordinación: sus cuartos apartados, o uno libre (primero en los pasillos de reserva).
      def plan_specials(halls_by_gender)
        COUPLES.each do |purpose, rol|
          people = @people.select { |person| person.rol == rol }
          place_group(people, purpose, nil, halls_by_gender, label: purpose == :direccion ? "el matrimonio director" : "el matrimonio de logística")
        end
        GENDERS.each do |gender|
          people = @people.select { |person| COORDINATION_ROLES.include?(person.rol) && person.gender == gender }
                          .sort_by { |person| person.coordinador? ? 0 : 1 }
          place_group(people, :coordinacion, gender, halls_by_gender,
                      label: gender == "M" ? "coordinación (mujeres)" : "coordinación (hombres)")
          committee = @people.select { |person| LOGISTICS_ROLES.include?(person.rol) && person.gender == gender }
          marked = @hallways.flat_map(&:rooms).select { |room| room.purpose_comite_logistica? && !taken?(room) }.sum(&:capacity)
          place_group(committee.shift(marked), :comite_logistica, gender, halls_by_gender, label: "logística")
          committee = share_adult_rooms(committee, gender)
          place_group(committee, :comite_logistica, gender, halls_by_gender,
                      label: gender == "M" ? "logística (mujeres)" : "logística (hombres)")
        end
      end

      # Las camas libres de los cuartos de adultos de ese género (consejeros y coordinación), en el orden del hotel.
      # Devuelve a quienes no cupieron.
      def share_adult_rooms(people, gender)
        waiting = people.dup
        @slots.values.select { |slot| %i[consejeros coordinacion].include?(slot.kind) && slot.gender == gender && slot.free.positive? }
              .sort_by { |slot| @room_order[slot.room.id] }
              .each { |slot| slot.occupants.concat(waiting.shift(slot.free)) }
        waiting
      end

      def place_group(people, purpose, gender, halls_by_gender, label:)
        return if people.empty?

        rooms = @hallways.flat_map(&:rooms)
        own_halls = gender ? halls_by_gender[gender] : []
        prefer = ->(room) { [ own_halls.any? { |hall| hall.id == room.hallway_id } ? 0 : 1, halls_by_gender[:spare].any? { |hall| hall.id == room.hallway_id } ? 0 : 1 ] }
        # Juntos y en el orden del hotel; entre los libres, el cuarto que mejor les quede de tamaño.
        marked = rooms.select { |room| room.purpose == purpose.to_s && !taken?(room) }
                      .sort_by { |room| [ *prefer.(room), @room_order[room.id] ] }
        leftover = rooms.select { |room| room.purpose_auto? && !taken?(room) }
                        .sort_by { |room| [ *prefer.(room), [ people.size - room.capacity, 0 ].max.zero? ? 0 : 1, @room_order[room.id] ] }
        waiting = people.dup
        (marked + leftover).each do |room|
          break if waiting.empty?
          # Un matrimonio no se separa: su cuarto tiene que caberlos a los dos.
          next if gender.nil? && room.capacity < waiting.size && room.purpose_auto?

          slot = open_slot(room, purpose, gender)
          slot.occupants.concat(waiting.shift(room.capacity))
        end
        return if waiting.empty?

        @warnings << "No quedó cuarto para #{label}: apártale uno en la configuración del hotel."
        waiting.each { |person| @unplaced << [ person, "Sin cuarto para #{label}" ] }
      end
  end
end
