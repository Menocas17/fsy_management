require "test_helper"

class CompanyRevealTest < ActionDispatch::IntegrationTest
  setup do
    CompanyReveal.close!
    @company = Company.create!(number: 12, nickname: "Los Valientes", dining_hall: :salon_las_americas)
    participants(:juan).update!(company: @company)
    Membership.create!(associable: @company, participant: participants(:maria))
    @partner = Participant.create!(first_name: "José", last_name: "Martínez", age: 27, gender: "H", rol: "consejero",
                                   stake: "bello_horizonte", ward: "la_rotonda", shirt_number: "l")
    Membership.create!(associable: @company, participant: @partner)
    @counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
  end

  test "with the companies closed the counselor sees theirs in figures, without a single name" do
    sign_in_as(@counselor)
    get company_path(@company)

    assert_response :success
    assert_select "[data-company-hidden]"
    assert_select "[data-companion]", text: /Ya está asignado/
    assert_select "[data-company-stakes]", text: /Estaca Bello Horizonte/
    assert_select "[data-company-stakes]", text: /Barrio La Rotonda/
    assert_select "[data-summary-card='jovenes']", text: /1/
    assert_select "[data-summary-card='comedor']", text: /Salón Las Américas/
    assert_select "[data-summary-card]", 2
    assert_not_includes response.body, "Juan"
    assert_not_includes response.body, "José Martínez"
  end

  test "with the companies closed the counselor can't reach their jóvenes or partner by another door" do
    sign_in_as(@counselor)

    [ participants_path, staff_participants_path, participant_path(participants(:juan)), participant_path(@partner),
      companies_path, company_night_attendance_path(@company), search_path(q: "Juan"), scan_path ].each do |path|
      get path
      assert_redirected_to my_company_path, "#{path} debería estar cerrado"
    end

    get participant_path(participants(:maria))
    assert_response :success

    get dashboard_path
    nav = css_select("nav a, dialog[data-dialog-name='mas'] a").map { |link| link.text.squish }
    assert_not_includes nav, "Jóvenes"
    assert_includes nav, "Organigrama"
    assert_not_includes nav, "Escanear gafete"
  end

  test "with the companies closed the counselor's organigrama shows only the top: no companies nor counselors" do
    auxiliar_company = AuxiliarCompany.create!(name: "Rama Norte")
    @company.update!(auxiliar_company: auxiliar_company)
    sign_in_as(@counselor)

    get organigrama_path(scope: "todo")
    assert_response :success
    assert_select "[data-org-view]", false
    assert_select "[data-node='coordinacion']"
    assert_select "[data-node='auxiliar']", text: /Rama Norte/
    assert_select "[data-company-id]", false
    assert_select "a[href^='#{auxiliar_company_path(auxiliar_company)}']", false
    assert_select "[data-org-branches-target='toggleAllButton']", false
    assert_not_includes response.body, "Compañía 12"
    assert_not_includes response.body, "José Martínez"
  end

  test "«Mi compañía» takes the counselor to their own company" do
    sign_in_as(@counselor)
    get my_company_path

    assert_redirected_to company_path(@company, return_to: dashboard_path)
  end

  test "direction opens the companies, the counselors get an alert and it stays in Historial" do
    sign_in_as(users(:one))
    get settings_path
    assert_select "#settings-companies [data-company-reveal-state='cerradas']"
    assert_select "#settings-companies form[data-turbo-confirm]"

    assert_difference -> { Alert.where(audience: :por_roles).count } => 1, -> { AuditLog.where(action: "companies_opened").count } => 1 do
      patch company_reveal_settings_path, params: { abrir: "1" }
    end
    assert_redirected_to settings_path(anchor: "settings-companies")
    assert CompanyReveal.open?
    assert_equal [ "consejero" ], Alert.where(audience: :por_roles).last.target_roles

    sign_in_as(@counselor)
    get company_path(@company)
    assert_select "[data-company-hidden]", false
    assert_includes response.body, "José Martínez"
    get participant_path(participants(:juan))
    assert_response :success
  end

  test "closing them again sends no alert" do
    CompanyReveal.open!
    sign_in_as(users(:one))

    assert_no_difference -> { Alert.count } do
      patch company_reveal_settings_path, params: { abrir: "0" }
    end
    assert_not CompanyReveal.open?
    assert AuditLog.exists?(action: "companies_closed")
  end

  test "only direction and the coordinators move the switch" do
    sign_in_as(@counselor)
    patch company_reveal_settings_path, params: { abrir: "1" }

    assert_redirected_to settings_path
    assert_not CompanyReveal.open?

    get settings_path
    assert_select "#settings-companies", false
  end

  test "the joven sees their company: counselors by name and companions by first name only" do
    CompanyReveal.open_to_jovenes!
    Participant.create!(first_name: "Valeria", last_name: "Gutiérrez", age: 16, gender: "M", rol: "joven",
                        stake: "las_americas", ward: "las_mercedes", shirt_number: "s", company: @company)
    participants(:juan).update!(room: "214")
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)))

    get my_company_path
    assert_response :success
    assert_select "[data-company-nickname]", text: "Los Valientes"
    assert_select "[data-my-counselors]", text: /José Martínez/
    assert_select "[data-my-counselors]", text: /María García/
    assert_select "[data-my-companions]", text: /Valeria G\./
    assert_not_includes css_select("[data-my-companions]").text, "Gutiérrez"
    assert_includes response.body, "Cuarto 214"
    assert_includes response.body, "Salón Las Américas"
  end

  test "a joven without company is told what comes next" do
    CompanyReveal.open_to_jovenes!
    participants(:juan).update!(company: nil)
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)))

    get my_company_path
    assert_select "[data-empty-state='no-company']"
  end

  test "with the companies closed logística doesn't see companies nor jóvenes, but keeps its own tools" do
    area = LogisticsArea.create!(name: "Tecnología")
    logistics = Participant.create!(first_name: "Sergio", last_name: "Prueba", age: 30, gender: "H", rol: "logistica",
                                    stake: "bello_horizonte", ward: "la_rotonda", shirt_number: "m", logistics_area: area)
    sign_in_as(User.create!(email_address: "sergio@fsy.com", password: "Logistica1!", participant: logistics))

    [ participants_path, participant_path(participants(:juan)), companies_path, company_path(@company), overview_companies_path,
      auxiliar_companies_path, company_night_attendance_path(@company) ].each do |path|
      get path
      assert_redirected_to dashboard_path, "#{path} debería estar cerrado para logística"
    end

    get staff_participants_path
    assert_response :success
    get participant_path(@partner)
    assert_response :success

    get organigrama_path(scope: "todo")
    assert_response :success
    assert_select "[data-org-view]", false
    assert_not_includes response.body, "Compañía 12"

    get search_path(q: "Juan")
    assert_response :success
    assert_not_includes response.body, "Juan Pérez"

    get dashboard_path
    nav = css_select("nav[aria-label='Navegación principal'] a").map { |link| link.text.squish }
    assert_not_includes nav, "Jóvenes"
    assert_not_includes nav, "Compañías"
    assert_includes nav, "Staff"
  end

  test "with the companies closed the auxiliar doesn't open their branch either" do
    auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company.update!(auxiliar_company: auxiliar_company)
    auxiliar = Participant.create!(first_name: "Byron", last_name: "Prueba", age: 30, gender: "H", rol: "auxiliar",
                                   stake: "bello_horizonte", ward: "la_rotonda", shirt_number: "m")
    Membership.create!(associable: auxiliar_company, participant: auxiliar)
    sign_in_as(User.create!(email_address: "byron@fsy.com", password: "Auxiliar1!", participant: auxiliar))

    get auxiliar_company_path(auxiliar_company)
    assert_redirected_to dashboard_path
    get my_company_path
    assert_redirected_to dashboard_path
  end

  test "full access sees every company and joven with the companies closed" do
    sign_in_as(users(:one))

    [ participants_path, participant_path(participants(:juan)), companies_path, company_path(@company) ].each do |path|
      get path
      assert_response :success, "#{path} debería abrir para el acceso total"
    end
    assert_select "[data-company-hidden]", false
  end

  test "opening the companies gives logística its pages back" do
    CompanyReveal.open!
    logistics = Participant.create!(first_name: "Sergio", last_name: "Prueba", age: 30, gender: "H", rol: "logistica",
                                    stake: "bello_horizonte", ward: "la_rotonda", shirt_number: "m")
    sign_in_as(User.create!(email_address: "sergio@fsy.com", password: "Logistica1!", participant: logistics))

    [ participants_path, participant_path(participants(:juan)), companies_path, company_path(@company) ].each do |path|
      get path
      assert_response :success, "#{path} debería abrir con las compañías abiertas"
    end
    get search_path(q: "Juan")
    assert_includes response.body, "Juan Pérez"
  end
end
