require "test_helper"

class RoomPlannerTest < ActiveSupport::TestCase
  setup do
    @companies = (1..4).map { |number| Company.create!(number: number) }
  end

  test "women and men sleep in their own hallways, jovenes only with jovenes, nobody alone, within capacity" do
    hallways("A" => "01-08", "B" => "09-16")
    people = jovenes(@companies, "M", 5) + jovenes(@companies, "H", 5) + counselors("M", 2) + counselors("H", 2)

    plan = RoomPlanner.new(seed: 3, people: people).call

    assert_empty plan.unplaced
    assert_equal people.size, plan.placed_count
    plan.slots.each_value do |slot|
      assert slot.occupants.size <= slot.room.capacity, "cuarto #{slot.room.number} sobre su capacidad"
      assert_equal [ slot.gender ], slot.occupants.map(&:gender).uniq, "cuarto #{slot.room.number} mezcla géneros"
      if slot.kind == :jovenes
        assert slot.occupants.all?(&:joven?), "un adulto en el cuarto de jóvenes #{slot.room.number}"
        assert slot.occupants.size >= 2, "un joven solo en el cuarto #{slot.room.number}"
      else
        assert slot.occupants.none?(&:joven?), "un joven en el cuarto de staff #{slot.room.number}"
      end
    end
    halls = plan.slots.values.group_by { |slot| slot.hallway.name }.transform_values { |slots| slots.map(&:gender).uniq }
    assert_equal({ "A" => [ "M" ], "B" => [ "H" ] }, halls, "mujeres primero, en el primer pasillo")
  end

  test "every hallway with jovenes gets a counselors room at its start, and a long one also at its end" do
    hallways("A" => "01-12")
    Hallway.find_by!(name: "A").update!(long: true)
    plan = RoomPlanner.new(people: jovenes(@companies, "M", 6) + counselors("M", 4)).call

    staff_rooms = plan.slots.values.select { |slot| slot.kind == :consejeros }.map { |slot| slot.room.number }
    assert_equal %w[01 12], staff_rooms.sort
    assert_equal 4, plan.slots.values.select { |slot| slot.kind == :consejeros }.sum { |slot| slot.occupants.size }
  end

  test "each company keeps its own rooms when there are beds to spare" do
    hallways("A" => "01-12")
    plan = RoomPlanner.new(seed: 9, people: jovenes(@companies, "M", 6) + counselors("M", 1)).call

    assert_equal 0, plan.mixed_rooms
    by_company = plan.jovenes_slots.flat_map { |slot| slot.occupants.map { |person| [ person.company_id, slot.room.number ] } }
                     .group_by(&:first).transform_values { |pairs| pairs.map(&:last).uniq.size }
    assert by_company.values.all? { |rooms| rooms == 2 }, "6 jóvenes en cuartos de 4 van en dos cuartos (3 y 3 o 4 y 2)"
  end

  test "a counselor sleeps in the hallway where most of their company is" do
    hallways("A" => "01-05", "B" => "06-10")
    first, last = @companies.first, @companies.last
    counselor_first = counselor("M", company: first)
    counselor_last = counselor("M", company: last)
    plan = RoomPlanner.new(people: jovenes([ first ], "M", 16) + jovenes([ last ], "M", 16) + [ counselor_last, counselor_first ]).call

    hall_of = ->(person) { plan.slots.values.find { |slot| slot.occupants.include?(person) }.hallway.name }
    assert_equal "A", hall_of.(counselor_first)
    assert_equal "B", hall_of.(counselor_last)
  end

  test "the same seed gives the same plan and another seed reorders" do
    hallways("A" => "01-10", "B" => "11-20")
    people = jovenes(@companies, "M", 7) + jovenes(@companies, "H", 7) + counselors("M", 2) + counselors("H", 2)

    first = RoomPlanner.new(seed: 11, people: people).call.assignments
    assert_equal first, RoomPlanner.new(seed: 11, people: people).call.assignments
    others = [ 12, 13, 14 ].map { |seed| RoomPlanner.new(seed: seed, people: people).call.assignments }
    assert others.any? { |assignments| assignments != first }
  end

  test "when the men's hallway is short they take the last rooms of the women's, flagged" do
    hallways("A" => "01-06", "B" => "07-09")
    Hallway.find_by!(name: "A").update!(gender: "M")
    Hallway.find_by!(name: "B").update!(gender: "H")
    plan = RoomPlanner.new(people: jovenes([ @companies.first ], "M", 8) + jovenes([ @companies.last ], "H", 14)).call

    assert_empty plan.unplaced
    spill = plan.slots.values.select(&:spill)
    assert spill.any?
    assert spill.all? { |slot| slot.gender == "H" && slot.hallway.name == "A" }
    assert_includes spill.map { |slot| slot.room.number }, "06", "toma los cuartos del final del pasillo"
  end

  test "the couples get their reserved rooms and coordination sleeps with the auxiliares of their gender" do
    hallways("A" => "01-06", "Z" => "90-93")
    Room.find_by!(number: "90").update!(purpose: :direccion)
    directors = [ adult("director", "H"), adult("director", "M") ]
    coordination = [ adult("coordinador", "M"), adult("auxiliar", "M"), adult("auxiliar", "H"), adult("coordinador", "H") ]
    logistics = [ adult("director_logistica", "H"), adult("director_logistica", "M") ]
    plan = RoomPlanner.new(people: jovenes(@companies, "M", 2) + directors + coordination + logistics).call

    assert_equal "90", plan.assignments[directors.first.id]
    assert_equal plan.assignments[directors.first.id], plan.assignments[directors.last.id]
    assert_equal plan.assignments[logistics.first.id], plan.assignments[logistics.last.id]
    assert_equal plan.assignments[coordination[0].id], plan.assignments[coordination[1].id]
    assert_equal plan.assignments[coordination[2].id], plan.assignments[coordination[3].id]
    assert_not_equal plan.assignments[coordination[0].id], plan.assignments[coordination[2].id]
    assert_empty plan.unplaced
  end

  test "rooms out of use are never taken" do
    hallways("A" => "01-04")
    Room.find_by!(number: "02").update!(purpose: :fuera_de_uso)
    plan = RoomPlanner.new(people: jovenes([ @companies.first ], "M", 8)).call

    assert_not plan.assignments.value?("02")
  end

  test "applying writes each room on the fichas and clears whoever was left out" do
    hallways("A" => "01-04")
    girls = jovenes([ @companies.first ], "M", 3).each(&:save!)
    stranger = Participant.create!(first_name: "Fuera", last_name: "Plan", age: 15, shirt_number: "m", gender: "M", rol: "joven",
                                   stake: "bello_horizonte", ward: "la_rotonda", room: "99")
    logistics = adult("logistica", "H").tap { |person| person.update!(room: "L1") }

    plan = RoomPlanner.new(people: girls).call
    plan.apply!

    assert girls.all? { |girl| girl.reload.room.present? }
    assert_nil stranger.reload.room, "fuera de la propuesta queda sin cuarto"
    assert_nil logistics.reload.room, "un cuarto escrito a mano no sobrevive"
  end

  test "everybody gets a room, the logistics committee apart by gender and never with jovenes" do
    hallways("A" => "01-08", "B" => "09-16")
    Participant.where.not(room: nil).update_all(room: "L1")
    committee = [ adult("logistica", "M"), adult("logistica", "M"), adult("logistica", "H") ]
    jovenes(@companies, "M", 3).each(&:save!)
    jovenes(@companies, "H", 3).each(&:save!)

    plan = RoomPlanner.new(seed: 2).call
    plan.apply!

    assert_empty plan.unplaced
    assert_equal 0, Participant.where(room: [ nil, "", "L1" ]).count, "todo el mundo tiene un cuarto del hotel"
    rooms = committee.map { |person| plan.slots.values.find { |slot| slot.occupants.include?(person) } }
    assert_equal [ :comite_logistica ], rooms.map(&:kind).uniq
    assert_equal rooms[0], rooms[1]
    assert_not_equal rooms[0], rooms[2]
    assert rooms.all? { |slot| slot.occupants.none?(&:joven?) && slot.occupants.map(&:gender).uniq.one? }
  end

  test "the hallway form understands ranges and keeps the zeros" do
    assert_equal %w[017 018 019 040], Hallway.parse_numbers("017-019, 040")
    hallway = Hallway.create!(name: "X", new_rooms: "7-9", new_rooms_capacity: 5)
    assert_equal [ [ "7", 5 ], [ "8", 5 ], [ "9", 5 ] ], hallway.rooms.map { |room| [ room.number, room.capacity ] }
    assert_not Hallway.new(name: "Y", new_rooms: "8").valid?, "el cuarto 8 ya existe"
  end

  test "renaming a room moves its occupants" do
    hallways("A" => "01")
    joven = participants(:juan).tap { |person| person.update!(room: "01") }
    Room.find_by!(number: "01").update!(number: "101")
    assert_equal "101", joven.reload.room
  end

  private
    def hallways(layout)
      layout.each_with_index do |(name, numbers), index|
        Hallway.create!(name: name, position: index + 1, new_rooms: numbers, new_rooms_capacity: 4)
      end
    end

    def jovenes(companies, gender, per_company)
      companies.flat_map do |company|
        Array.new(per_company) { |index| build("Joven#{company.number}#{gender}#{index}", "joven", gender, company: company) }
      end
    end

    def counselors(gender, count)
      Array.new(count) { |index| counselor(gender, company: @companies[index % @companies.size]) }
    end

    def counselor(gender, company:)
      build("Consejero#{gender}#{company.number}", "consejero", gender, company_id: company.id)
    end

    def adult(rol, gender)
      Participant.create!(first_name: "#{rol}#{gender}", last_name: "Prueba", age: 40, stake: "bello_horizonte",
                          ward: "la_rotonda", shirt_number: "m", gender: gender, rol: rol)
    end

    def build(name, rol, gender, **attrs)
      Participant.new(id: SecureRandom.uuid, first_name: name, last_name: "Prueba", age: rol == "joven" ? 15 : 30,
                      stake: "bello_horizonte", ward: "la_rotonda", shirt_number: "m", gender: gender, rol: rol, **attrs)
    end
end
