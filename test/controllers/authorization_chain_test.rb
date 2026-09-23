require "test_helper"

# La cadena de mando completa: quién puede editar a quién y qué parte de cada compañía.
class AuthorizationChainTest < ActionDispatch::IntegrationTest
  setup do
    @auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 1, auxiliar_company: @auxiliar_company)
    @other_company = Company.create!(number: 2)

    @joven = create_participant(rol: :joven, gender: "H", company: @company)
    @other_joven = create_participant(rol: :joven, gender: "M", company: @other_company)
    @counselor = create_participant(rol: :consejero, gender: "H")
    @auxiliar = create_participant(rol: :auxiliar, gender: "M")
    @logistics_member = create_participant(rol: :logistica, gender: "H")

    Membership.create!(associable: @company, participant: @counselor)
    Membership.create!(associable: @auxiliar_company, participant: @auxiliar)
  end

  # Consejero ------------------------------------------------------------------

  test "a consejero edits the jóvenes of their own company" do
    sign_in_as_participant(@counselor)

    get edit_participant_path(@joven)
    assert_response :success

    patch participant_path(@joven), params: { participant: { room: "204" } }
    assert_equal "204", @joven.reload.room
  end

  test "a consejero cannot edit jóvenes of another company, nor any staff" do
    sign_in_as_participant(@counselor)

    [ @other_joven, @auxiliar, @logistics_member ].each do |target|
      get edit_participant_path(target)
      assert_redirected_to participants_path

      patch participant_path(target), params: { participant: { room: "999" } }
      refute_equal "999", target.reload.room, "#{target.rol} no debería ser editable por un consejero"
    end
  end

  test "a consejero only renames their own company and never touches its staffing" do
    sign_in_as_participant(@counselor)

    patch company_path(@company), params: { company: { nickname: "Guerreros", dining_hall: "salon_nicaragua" } }
    @company.reload
    assert_equal "Guerreros", @company.nickname
    assert_nil @company.dining_hall, "el consejero no cambia el comedor"

    spare = create_participant(rol: :consejero, gender: "M")
    assert_no_difference -> { @company.memberships.count } do
      post assign_staff_company_path(@company), params: { participant_id: spare.id }
    end
    assert_redirected_to @company
  end

  test "a consejero cannot edit their auxiliar company" do
    sign_in_as_participant(@counselor)

    get edit_auxiliar_company_path(@auxiliar_company)
    assert_redirected_to @auxiliar_company
  end

  # Auxiliar -------------------------------------------------------------------

  test "an auxiliar edits the jóvenes of their branch but not its counselors" do
    sign_in_as_participant(@auxiliar)

    patch participant_path(@joven), params: { participant: { room: "301" } }
    assert_equal "301", @joven.reload.room

    get edit_participant_path(@counselor)
    assert_redirected_to participants_path
  end

  test "an auxiliar manages their companies except moving them to another branch" do
    sign_in_as_participant(@auxiliar)
    other_branch = AuxiliarCompany.create!(name: "Auxiliar Beta")

    patch company_path(@company), params: { company: { dining_hall: "salon_las_americas", auxiliar_company_id: other_branch.id } }
    @company.reload
    assert_equal "salon_las_americas", @company.dining_hall
    assert_equal @auxiliar_company, @company.auxiliar_company, "la compañía no cambia de rama"

    spare = create_participant(rol: :consejero, gender: "M")
    assert_difference -> { @company.memberships.count }, 1 do
      post assign_staff_company_path(@company), params: { participant_id: spare.id }
    end
  end

  test "an auxiliar renames their auxiliar company but does not name its coordinators" do
    sign_in_as_participant(@auxiliar)
    coordinator = create_participant(rol: :coordinador, gender: "H")

    patch auxiliar_company_path(@auxiliar_company), params: { auxiliar_company: { name: "Rama Alfa", coordinator_id: coordinator.id } }
    @auxiliar_company.reload
    assert_equal "Rama Alfa", @auxiliar_company.name
    assert_nil @auxiliar_company.coordinator_id
  end

  # Logística ------------------------------------------------------------------

  test "the logistics director only reaches their own committee" do
    director = create_participant(rol: :director_logistica, gender: "H")
    sign_in_as_participant(director)

    patch participant_path(@logistics_member), params: { participant: { room: "L1" } }
    assert_equal "L1", @logistics_member.reload.room

    get edit_participant_path(@joven)
    assert_redirected_to participants_path

    assert_difference -> { Participant.logistica.count }, 1 do
      post participants_path, params: { participant: {
        first_name: "Nuevo", last_name: "Logística", age: 30, stake: "las_americas",
        shirt_number: "m", gender: "H", rol: "logistica" } }
    end
  end

  test "the logistics director cannot register anybody outside logistics" do
    director = create_participant(rol: :director_logistica, gender: "H")
    sign_in_as_participant(director)

    assert_no_difference -> { Participant.count } do
      post participants_path, params: { participant: {
        first_name: "Intruso", last_name: "Coordinador", age: 30, stake: "las_americas",
        shirt_number: "m", gender: "H", rol: "coordinador" } }
    end
    assert_redirected_to participants_path
  end

  test "a plain logistics member edits nobody, not even their own role" do
    sign_in_as_participant(@logistics_member)

    get edit_participant_path(@joven)
    assert_redirected_to participants_path

    get new_participant_path
    assert_redirected_to dashboard_path

    patch participant_path(@logistics_member), params: { participant: { room: "L9", rol: "coordinador" } }
    @logistics_member.reload
    assert_equal "L9", @logistics_member.room, "su propia ficha sí la edita"
    assert_equal "logistica", @logistics_member.rol, "pero no se cambia el rol"
  end

  # Registrador y acceso total --------------------------------------------------

  test "a registrador registers and edits jóvenes only" do
    registrar = create_participant(rol: :registrador, gender: "M")
    sign_in_as_participant(registrar)

    assert_difference -> { Participant.joven.count }, 1 do
      post participants_path, params: { participant: {
        first_name: "Nueva", last_name: "Joven", age: 15, stake: "las_americas",
        shirt_number: "s", gender: "M", rol: "joven" } }
    end

    patch participant_path(@other_joven), params: { participant: { room: "105" } }
    assert_equal "105", @other_joven.reload.room

    get edit_participant_path(@counselor)
    assert_redirected_to participants_path
  end

  test "a coordinador reaches every ficha and every company" do
    coordinator = create_participant(rol: :coordinador, gender: "H")
    sign_in_as_participant(coordinator)

    patch participant_path(@counselor), params: { participant: { room: "A1", rol: "consejero" } }
    assert_equal "A1", @counselor.reload.room

    patch company_path(@company), params: { company: { dining_hall: "salon_nicaragua" } }
    assert_equal "salon_nicaragua", @company.reload.dining_hall
  end

  test "nobody but full access deletes fichas outside their own scope" do
    sign_in_as_participant(@counselor)
    assert_no_difference -> { Participant.count } do
      delete participant_path(@joven)
    end

    sign_in_as(users(:one))
    assert_difference -> { Participant.count }, -1 do
      delete participant_path(@joven)
    end
  end

  private
    def create_participant(rol:, gender:, company: nil)
      Participant.create!(first_name: "Persona", last_name: rol.to_s.titleize, age: 25,
                          stake: "bello_horizonte", shirt_number: "m", gender: gender, rol: rol, company: company)
    end

    def sign_in_as_participant(participant)
      sign_in_as(User.create!(email_address: "#{participant.id}@fsy.com", password: "Password1!", participant: participant))
    end
end
