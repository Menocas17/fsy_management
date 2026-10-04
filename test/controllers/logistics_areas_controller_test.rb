require "test_helper"

class LogisticsAreasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @registro = LogisticsArea.create!(name: "Registro", checkin: true)
    @decoracion = LogisticsArea.create!(name: "Decoración")
    @director = person("director_logistica", "Diego")
    @luis = person("logistica", "Luis", area: @decoracion)
    sign_in_as(account_for(@director))
  end

  test "the logistics director sees every area with its flags, and who has no area" do
    sin_area = person("logistica", "Sara")

    get logistics_areas_path

    assert_response :success
    assert_select "[data-area='Registro'] [data-flag='checkin']"
    assert_select "[data-area='Decoración']", text: /Sin permisos extra/
    assert_select "[data-unassigned]", text: /#{sin_area.full_name}/
  end

  test "what each flag does is just its pills: a note on hover and a dialog for touch screens" do
    get logistics_areas_path

    assert_select "[data-flags-help] button[data-action='flag-help#open']", LogisticsArea::FLAGS.size
    assert_select "[data-flags-help] [data-flag-tip='finance']", text: /no los aprueba/
    assert_select "dialog[data-flag-help-target='dialog'][data-flag='nursing']"
    assert_select "details[data-flags-help]", 0, "it no longer folds open"
  end

  test "an area is created with its flags" do
    post logistics_areas_path, params: { logistics_area: { name: " Alimentación ", description: "Comidas", food: "1" } }

    area = LogisticsArea.find_by!(name: "Alimentación")
    assert_redirected_to logistics_area_path(area)
    assert_equal [ :food ], area.flags
    assert_equal "logistica", AuditLog.order(:created_at).last.category
  end

  test "a switch turns one flag on or off and leaves the rest alone" do
    patch logistics_area_path(@registro), params: { logistics_area: { finance: true } }

    assert_equal %i[checkin finance], @registro.reload.flags
    assert_match(/Dio el permiso de Finanzas al área Registro/, AuditLog.order(:created_at).last.summary)

    get logistics_area_path(@registro)
    assert_select "[data-flag-switch='finance'][role='switch'][aria-checked='true']"
    assert_select "[data-flag-switch='food'][aria-checked='false']"
  end

  test "adding someone from another area moves them, and gives them the area's permissions" do
    assert_not account_for(@luis).checkin_registrar?

    post logistics_area_members_path(@registro), params: { participant_id: @luis.id }

    assert_equal @registro, @luis.reload.logistics_area
    assert account_for(@luis).checkin_registrar?
    assert_match(/Pasó a Luis Prueba al área Registro \(estaba en Decoración\)/, AuditLog.order(:created_at).last.summary)
  end

  test "the area page offers the committee, saying where each one is now" do
    get logistics_area_path(@registro)

    assert_select "[data-area-candidates]", text: /Luis Prueba.*Está en Decoración/m
  end

  test "removing someone leaves them without area" do
    @luis.update!(logistics_area: @registro)

    delete logistics_area_member_path(@registro, @luis)

    assert_nil @luis.reload.logistics_area
  end

  test "only the logistics committee can be added" do
    joven = participants(:juan)

    post logistics_area_members_path(@registro), params: { participant_id: joven.id }

    assert_response :not_found
    assert_nil joven.reload.logistics_area
  end

  test "deleting an area leaves its members without area, unless it has expenses" do
    @luis.update!(logistics_area: @decoracion)
    delete logistics_area_path(@decoracion)
    assert_redirected_to logistics_areas_path
    assert_nil @luis.reload.logistics_area

    Expense.create!(concept: "Agua", estimated_cents: 1000, presented_by: @director, presented_by_name: @director.full_name, logistics_area: @registro)
    delete logistics_area_path(@registro)
    assert_redirected_to logistics_area_path(@registro)
    assert LogisticsArea.exists?(@registro.id)
  end

  test "food is a flag like the others, for the future food module" do
    alimentacion = LogisticsArea.create!(name: "Alimentación", food: true)
    cocinera = person("logistica", "Carla", area: alimentacion)

    assert account_for(cocinera).food_member?
    assert_not account_for(@luis).food_member?
  end

  test "nobody else manages areas, nor sees the menu entry" do
    sign_in_as(account_for(@luis))

    get logistics_areas_path
    assert_redirected_to dashboard_path

    patch logistics_area_path(@registro), params: { logistics_area: { finance: true } }
    assert_not @registro.reload.finance?

    get dashboard_path
    assert_select "aside a[href='#{logistics_areas_path}']", 0
  end

  test "full access manages them too" do
    sign_in_as(users(:one))

    get logistics_areas_path
    assert_response :success
    assert_select "aside a[href='#{logistics_areas_path}'][aria-current='page']", text: "Áreas"
  end

  private
    def person(rol, name, area: nil)
      Participant.create!(first_name: name, last_name: "Prueba", age: 30, stake: "villa_flor", shirt_number: "m",
                          gender: "H", rol: rol, logistics_area: area)
    end

    def account_for(participant)
      participant.user || User.create!(email_address: "#{participant.first_name.downcase}.#{participant.id.first(4)}@fsy.com",
                                       password: "Cuenta123!", participant: participant)
    end
end
