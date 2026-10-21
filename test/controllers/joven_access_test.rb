require "test_helper"

class JovenAccessTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(number: 4)
    participants(:juan).update!(company: @company)
    Membership.create!(associable: @company, participant: participants(:maria))
    @joven = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan))
  end

  test "the joven opens their own things" do
    sign_in_as(@joven)

    [ dashboard_path, agenda_path, my_company_path, myprofile_participants_path, participant_path(participants(:juan)),
      edit_participant_path(participants(:juan)), participant_qr_path(participants(:juan)), notifications_path,
      changelog_path, settings_path, edit_password_change_path ].each do |path|
      get path
      assert_response :success, "#{path} debería abrir para el joven"
    end
  end

  test "the staff's pages send the joven back home, whatever the address" do
    sign_in_as(@joven)

    [ participants_path, staff_participants_path, participant_path(participants(:maria)), edit_participant_path(participants(:maria)),
      companies_path, company_path(@company), auxiliar_companies_path, search_path(q: "María"), scan_path,
      agenda_trainings_path, rooms_path, infirmary_visits_path, inventories_path, finances_path, reports_path, alerts_path,
      new_alert_path, audit_logs_path, assignments_path, logistics_areas_path, company_suggestions_path, overview_companies_path,
      company_night_attendance_path(@company) ].each do |path|
      get path
      assert_redirected_to dashboard_path, "#{path} debería estar cerrado para el joven"
    end
  end

  test "the organigrama only shows the joven their own company's chain" do
    CompanyReveal.open_to_jovenes!
    sign_in_as(@joven)

    get organigrama_path
    assert_response :success
    assert_select "[data-org-view]", false
    assert_includes response.body, "María García"
  end

  test "the joven can't change someone else's ficha nor ask for their QR" do
    sign_in_as(@joven)

    patch participant_path(participants(:maria)), params: { participant: { first_name: "Otra" } }
    assert_redirected_to dashboard_path
    assert_equal "María", participants(:maria).reload.first_name

    get participant_qr_path(participants(:maria))
    assert_response :forbidden
  end

  test "the joven's menu and home only show their own things" do
    @joven.update!(simple_mode: false)
    sign_in_as(@joven)
    get dashboard_path

    assert_equal [ "Inicio", "Mi compañía", "Agenda", "Mi perfil", "Novedades", "Configuración" ],
                 css_select("nav[aria-label='Navegación principal'] a").map { |link| link.text.squish }.uniq
    assert_select "[data-joven-home]"
    assert_select "[data-stat-tile]", false
    assert_select "form[role='search']", false
    assert_select "[data-shortcut='qr']", false

    get agenda_path
    assert_select "[data-agenda-view='capacitaciones']", false
  end

  test "staff keeps opening the lists" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get participants_path
    assert_response :success
  end
end
