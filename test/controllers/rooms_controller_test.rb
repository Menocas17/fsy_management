require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(number: 3)
    Hallway.create!(name: "A1", position: 1, new_rooms: "017-020", new_rooms_capacity: 4)
    Hallway.create!(name: "A2", position: 2, new_rooms: "021-024", new_rooms_capacity: 4)
    @girls = Array.new(3) { |index| person("Ana#{index}", "joven", "M", company: @company, room: "018") }
    @boy = person("Pedro", "joven", "H", company: @company, room: "021")
    @counselor = person("Carla", "consejero", "M")
    @director = person("Dir", "director", "H")
    @logistics_director = person("Lore", "director_logistica", "M")
  end

  test "the staff sees the board with each room colored by gender and what needs a look" do
    sign_in_as account(@counselor)

    get rooms_path
    assert_response :success
    assert_select "[data-room-tile='018'][data-room-gender=M]", text: %r{3/4}
    assert_select "[data-room-tile='021'][data-room-gender=H]"
    assert_select "[data-room-issues]", text: /Un joven solo/
    assert_select "[data-without-room]", text: /Carla/
    assert_select "nav a[href='#{rooms_path}']", text: /Cuartos/
    assert_select "[data-rooms-action=ordenar]", 0, "un consejero no ordena los cuartos"

    get room_path("018")
    assert_response :success
    assert_select "[data-room-occupants] li", 3
  end

  test "jovenes don't open the rooms board" do
    sign_in_as account(@girls.first)

    get rooms_path
    assert_redirected_to dashboard_path
  end

  test "a counselor can't order the rooms" do
    sign_in_as account(@counselor)

    get room_plan_path
    assert_redirected_to rooms_path
    post room_plan_path
    assert_redirected_to rooms_path
    assert_equal "018", @girls.first.reload.room
  end

  test "the director previews a plan, reorders and applies it" do
    sign_in_as account(@director)

    get room_plan_path
    assert_response :success
    assert_select "[data-rooms-action=reordenar]"
    assert_select "[data-hallway=A1] [data-room-tile]", 4
    fingerprint = css_select("input[name=huella]").first["value"]

    assert_difference -> { AuditLog.where(category: "cuartos").count } do
      post room_plan_path, params: { semilla: "", huella: fingerprint }
    end
    assert_redirected_to rooms_path
    assert @girls.map { |girl| girl.reload.room }.uniq.one?, "las tres juntas"
    assert_not_equal @boy.reload.room, @girls.first.room
    assert @counselor.reload.room.present?
  end

  test "a plan that changed since the preview is shown again instead of applied" do
    sign_in_as account(@logistics_director)

    post room_plan_path, params: { semilla: "5", huella: "vieja" }
    assert_redirected_to room_plan_path(semilla: 5)
    assert_equal "021", @boy.reload.room
  end

  test "the hotel is configured by hallways and rooms" do
    Hallway.destroy_all
    sign_in_as account(@director)

    post load_layout_hallways_path
    assert_redirected_to hallways_path
    assert_equal Room.count, Room.where(capacity: Room::DEFAULT_CAPACITY).count
    assert Hallway.find_by!(name: "A1").long?
    assert_equal "017", Hallway.find_by!(name: "A1").rooms.first.number

    hallway = Hallway.find_by!(name: "C3")
    room = hallway.rooms.first
    patch hallway_path(hallway), params: { hallway: { gender: "H", new_rooms: "165",
                                                     rooms_attributes: { "0" => { id: room.id, capacity: "5", purpose: "coordinacion" } } } }
    assert_redirected_to hallways_path
    assert hallway.reload.for_H?
    assert_equal [ [ "164", 5, "coordinacion" ], [ "165", 4, "auto" ] ], hallway.rooms.map { |r| [ r.number, r.capacity, r.purpose ] }
    assert_match "C3", AuditLog.where(category: "cuartos").last.summary

    get edit_hallway_path(hallway)
    assert_response :success
  end

  test "the company profile paints each room by gender" do
    sign_in_as account(@counselor)

    get company_path(@company)
    assert_response :success
    assert_select "a[data-room='018'][data-room-gender=M]", text: /3 jóv/
    assert_select "a[data-room='021'][data-room-gender=H]"
  end

  private
    def person(name, rol, gender, **attrs)
      Participant.create!(first_name: name, last_name: "Prueba", age: rol == "joven" ? 15 : 30, stake: "bello_horizonte",
                          ward: "la_rotonda", shirt_number: "m", gender: gender, rol: rol, **attrs)
    end

    def account(participant)
      User.create!(email_address: "#{participant.first_name.downcase}@fsy.com", password: "Prueba123!", participant: participant)
    end
end
