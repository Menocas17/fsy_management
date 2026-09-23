require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "renders the hero and the headline totals" do
    get dashboard_path

    assert_response :success
    assert_select "h1[data-controller='countdown'][data-countdown-starts-at-value]", text: /Faltan para el inicio/
    assert_select "[data-countdown-target='days']"
    assert_includes response.body, "Comienza el Lunes 11 de enero de 2027"
    assert_select "[data-kpi='total_jovenes']", text: "1"
    assert_select "[data-kpi='total_staff']", text: "1"
    assert_select "[data-kpi='total_participants']", text: "2"
  end

  test "shows the new-participant shortcut to admins" do
    get dashboard_path

    assert_select "a[href='#{new_participant_path}']", text: /Nuevo participante/
  end

  test "the QR shortcut sits next to it, still inert" do
    get dashboard_path

    assert_select "[data-shortcut='qr'][aria-disabled='true']", text: /Escanear QR/
    assert_select "a[data-shortcut='my-company']", false
  end

  test "a consejero only gets a shortcut to the company they staff" do
    company = Company.create!(number: 7)
    Membership.create!(associable: company, participant: participants(:maria))
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get dashboard_path

    assert_select "a[data-shortcut='my-company'][href='#{company_path(company)}']", text: /Ver mi compañía/
    assert_select "a[href='#{new_participant_path}']", false
    assert_select "[data-shortcut='qr']", false
  end

  test "an auxiliar is sent to their auxiliar company instead" do
    auxiliar = participants(:maria).dup
    auxiliar.update!(rol: :auxiliar, first_name: "Ana")
    auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar 1")
    Membership.create!(associable: auxiliar_company, participant: auxiliar)
    sign_in_as(User.create!(email_address: "ana@fsy.com", password: "Auxiliar1!", participant: auxiliar))

    get dashboard_path

    assert_select "a[data-shortcut='my-company'][href='#{auxiliar_company_path(auxiliar_company)}']"
  end

  test "someone without a company gets no shortcut at all" do
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)))

    get dashboard_path

    assert_select "a[data-shortcut='my-company']", false
    assert_select "a[href='#{new_participant_path}']", false
  end

  test "renders ApexCharts mounts with their data and a text alternative" do
    get dashboard_path

    assert_select "[data-controller='chart'][data-chart-kind-value='columns']", 2
    assert_select "[data-controller='chart'][data-chart-kind-value='donut'][role='img'][aria-label^='Distribución por rol']", 1
    assert_select "[data-controller='chart'] [data-chart-target='canvas']", 3
  end

  test "age and gender charts only count jóvenes, not staff" do
    get dashboard_path

    assert_select "[data-kpi='male_count']", "1"
    assert_select "[data-kpi='female_count']", "0"
    age_chart = css_select("[data-controller='chart'][aria-label^='Jóvenes por edad']").first
    assert_includes age_chart["aria-label"], "20: 1"
    refute_includes age_chart["aria-label"], "25"
  end

  test "counts shirt sizes, defaulting missing sizes to zero" do
    get dashboard_path

    assert_select "[data-shirt-size='m']", text: "1"
    assert_select "[data-shirt-size='s']", text: "1"
    assert_select "[data-shirt-size='xl']", text: "0"
  end
end
