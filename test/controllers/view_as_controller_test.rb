require "test_helper"

class ViewAsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @branch = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 3, auxiliar_company: @branch)
    participants(:juan).update!(company: @company)

    @counselor = participants(:maria)
    @company.memberships.create!(participant: @counselor)
    @auxiliar = person("Laura", "auxiliar", "M")
    @branch.memberships.create!(participant: @auxiliar)
    @director = person("Dir", "director", "H")
    @coordinator = person("Cora", "coordinador", "M")
    @logistics_director = person("Lalo", "director_logistica", "H")
    @registrar = person("Rita", "logistica", "M", logistics_area: LogisticsArea.create!(name: "Registro", checkin: true))
    @nurse = person("Patricia", "logistica", "M", logistics_area: LogisticsArea.create!(name: "Enfermería", nursing: true))
    # Solo algunas tienen cuenta: las demás se ven con una cuenta de mentira que no se guarda.
    User.create!(email_address: "rita@fsy.com", password: "Prueba123!", participant: @registrar)
  end

  test "the superadmin walks every menu page as each role, with that role's menu" do
    sign_in_as @admin

    Participant::VIEW_AS_ROLES.each do |rol|
      post view_as_path, params: { rol: rol }
      assert_redirected_to dashboard_path
      get dashboard_path
      assert_response :success
      assert_select "[data-view-as-banner]", text: /#{Participant.role_label(rol)}/

      nav = css_select("nav a[href^='/']").map { |link| link["href"] }.uniq
      assert_not_empty nav
      nav.each do |href|
        get href
        assert_includes [ 200, 302 ], response.status, "#{rol} → #{href}"
        assert_redirected_to(dashboard_path) if response.redirect? && rol != "consejero"
      end
    end
  end

  test "a counselor's menu hides the modules they can't open" do
    sign_in_as @admin
    post view_as_path, params: { rol: "consejero" }
    get dashboard_path

    assert_select "nav", text: /Asistencia nocturna/
    %w[Inventario Finanzas Reportes Librería Historial Alertas Áreas].each do |hidden|
      assert_select "nav", { text: /#{hidden}/, count: 0 }, "#{hidden} is not in a counselor's menu"
    end
  end

  test "the counselor sample is the one with a company and edits are that counselor's" do
    other = person("Otro", "consejero", "H")
    sign_in_as @admin
    post view_as_path, params: { rol: "consejero" }
    follow_redirect!
    assert_select "[data-view-as-banner]", text: /María García/
    assert_not_equal other.id, session[:view_as_participant_id]

    get edit_participant_path(@auxiliar)
    assert_response :redirect, "a counselor can't edit an auxiliar"
  end

  test "a specific ficha, and coming back" do
    sign_in_as @admin
    get participant_path(@nurse)
    assert_select "[data-view-as-participant]"

    post view_as_path, params: { participant_id: @nurse.id }
    follow_redirect!
    assert_select "[data-view-as-banner]", text: /Patricia/
    assert_select "nav", text: /Enfermería/

    delete view_as_path
    follow_redirect!
    assert_select "[data-view-as-banner]", 0
    assert_select "nav", text: /Historial/
  end

  test "reading the notifications while viewing as marks nothing as read for that person" do
    sign_in_as @admin
    Alert.create!(title: "Aviso", body: "Texto", sender_name: "Marta", audience: :todos)

    post view_as_path, params: { participant_id: @nurse.id }
    get notifications_path
    assert_response :success, "a ficha without an account has nowhere to write it"

    post view_as_path, params: { participant_id: @registrar.id }
    get notifications_path
    patch read_notifications_path
    assert_nil @registrar.user.reload.alerts_read_at
  end

  test "actions while viewing as are logged under the superadmin" do
    sign_in_as @admin
    post view_as_path, params: { participant_id: @coordinator.id }
    patch participant_path(participants(:juan)), params: { participant: { first_name: "Juanito" } }

    log = AuditLog.order(:id).last
    assert_equal "Administrador del sistema (viendo como Cora Prueba)", log.actor_name
  end

  test "only the superadmin views as someone, and nobody as a joven" do
    sign_in_as User.find_by!(email_address: "rita@fsy.com")
    post view_as_path, params: { rol: "director" }
    assert_redirected_to dashboard_path
    assert_nil session[:view_as_participant_id]

    sign_in_as @admin
    post view_as_path, params: { participant_id: participants(:juan).id }
    assert_nil session[:view_as_participant_id]
  end

  test "the password can't be changed while viewing as someone" do
    sign_in_as @admin
    post view_as_path, params: { participant_id: @registrar.id }
    get edit_password_change_path
    assert_redirected_to settings_path
  end

  private
    def person(name, rol, gender, **attrs)
      Participant.create!(first_name: name, last_name: "Prueba", age: 30, stake: "bello_horizonte", ward: "la_rotonda",
                          shirt_number: "m", gender: gender, rol: rol, **attrs)
    end
end
