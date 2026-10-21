require "test_helper"

# El joven no ve su compañía hasta que el director de logística finaliza el registro (CompanyReveal): mientras,
# «Próximamente». Al finalizarlo la ve completa y le llega un aviso.
class JovenCompanyComingSoonTest < ActionDispatch::IntegrationTest
  setup do
    CompanyReveal.close_to_jovenes!
    @company = Company.create!(number: 7, nickname: "Los Valientes", dining_hall: :salon_las_americas)
    participants(:juan).update!(company: @company, room: "214")
    Membership.create!(associable: @company, participant: participants(:maria))
    @joven = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan))
  end

  test "before the registro is finished the joven only sees Próximamente, not a single detail of their company" do
    sign_in_as(@joven)

    get dashboard_path
    assert_select "[data-joven-home] [data-company-coming-soon][href='#{my_company_path}']", text: /Próximamente/
    assert_select "[data-bottom-nav-item='Mi compañía']"

    get my_company_path
    assert_select "[data-company-coming-soon]", text: /Próximamente/
    assert_select "[data-coming-soon-preview] li", 5

    get myprofile_participants_path
    assert_includes response.body, "Próximamente"

    [ dashboard_path, my_company_path, myprofile_participants_path, edit_participant_path(participants(:juan)) ].each do |path|
      get path
      [ "Los Valientes", "Compañía 7", "María García", "214", "Salón Las Américas" ].each do |detail|
        assert_not_includes response.body, detail, "#{path} no debería mostrar «#{detail}»"
      end
    end

    get organigrama_path
    assert_redirected_to my_company_path
  end

  test "the staff keeps seeing the joven's company" do
    sign_in_as(users(:one))

    get participant_path(participants(:juan))
    assert_includes response.body, @company.name
    assert_includes response.body, "214"
  end

  test "finishing the registro opens their company and sends them one alert; reopening hides it again silently" do
    sign_in_as(users(:one))
    get checkins_path
    assert_select "[data-registro-finish='abierto'] form[action='#{finish_checkins_path}'][data-turbo-confirm]"

    assert_difference -> { Alert.count }, 1 do
      patch finish_checkins_path
      patch finish_checkins_path
    end
    assert_redirected_to checkins_path
    assert CompanyReveal.open_to_jovenes?
    alert = Alert.last
    assert_equal [ "joven" ], alert.target_roles
    assert_equal "/mi-compania", alert.link_path
    assert AuditLog.exists?(category: "registro", action: "registro_finished")

    get checkins_path
    assert_select "[data-registro-finish='finalizado']"

    assert_no_difference -> { Alert.count } do
      delete finish_checkins_path
    end
    assert_not CompanyReveal.open_to_jovenes?
    assert AuditLog.exists?(category: "registro", action: "registro_reopened")
  end

  test "after finishing the joven sees their company" do
    CompanyReveal.open_to_jovenes!
    sign_in_as(@joven)

    get my_company_path
    assert_select "[data-company-coming-soon]", false
    assert_select "[data-company-nickname]", text: "Los Valientes"
    assert_includes response.body, "Cuarto 214"
  end

  test "only whoever manages the registros finishes it, and never from a training's registro" do
    area = LogisticsArea.create!(name: "Registro", checkin: true)
    member = Participant.create!(first_name: "Rosa", last_name: "Pérez", age: 30, gender: "M", rol: "logistica",
                                 stake: "las_americas", ward: "las_mercedes", shirt_number: "m", logistics_area: area)
    sign_in_as(User.create!(email_address: "rosa@fsy.com", password: "Registro1!", participant: member))

    get checkins_path
    assert_select "[data-registro-finish]", false

    patch finish_checkins_path
    assert_redirected_to checkins_path
    assert_not CompanyReveal.open_to_jovenes?
    assert_equal 0, Alert.count
  end

  test "the joven gets their own tutorial, with Próximamente while their company is closed" do
    sign_in_as(@joven)

    get settings_path
    assert_select "[data-settings-tutorial]"

    post tutorial_path, as: :json
    assert_response :success
    ids = response.parsed_body["steps"].map { |step| step["id"] }
    assert_equal "joven_welcome", ids.first
    assert_includes ids, "joven_coming_soon"
    assert_not_includes ids, "joven_my_company"
    assert_includes ids, "joven_sheet_settings"
    assert_not_includes ids, "kpis", "no recorre lo del staff"
    assert_not_includes ids, "account", "el joven no tiene menú de cuenta"

    CompanyReveal.open_to_jovenes!
    post tutorial_path, as: :json
    ids = response.parsed_body["steps"].map { |step| step["id"] }
    assert_includes ids, "joven_my_company"
    assert_not_includes ids, "joven_coming_soon"

    patch tutorial_path
    assert_predicate @joven.reload.tutorial_completed_at, :present?
  end
end
