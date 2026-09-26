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

  test "the hero shows the FSY lockup, with the pill as its small-screen stand-in" do
    get dashboard_path

    assert_select "[data-hero-lettering][class*='lg:block']", 1
    assert_select "span[class*='lg:hidden']", text: /FSY 2026 · Managua-Caribe/
  end

  test "every card heading carries its own icon tile" do
    get dashboard_path

    # Lo que viene, cocina, estaca, rol, género, tallas y edad; los tres totales no llevan cabecera.
    assert_select "section h2", 7
    %w[map-pin user-cog venus-and-mars shirt cake].each do |lucide|
      assert_select "[data-card-icon='#{lucide}'] svg", { count: 1 }, "falta la baldosa con el icono #{lucide}"
    end
  end

  test "before the event it lists the trainings that are left and the start" do
    get dashboard_path

    assert_select "[data-next-up]", 1
    assert_select "[data-next-item='training-2026-10-17']", text: /17 de octubre/
    assert_select "[data-next-item='training-2026-11-17']", text: /17 de noviembre/
    assert_select "[data-next-item='event']", text: /Comienza el evento/
    assert_select "[data-next-item='training-2026-12-17']", 0, "solo las dos próximas capacitaciones"
  end

  test "a training that already happened drops off the list" do
    travel_to Date.new(2026, 10, 18) do
      get dashboard_path

      assert_select "[data-next-item='training-2026-10-17']", 0
      assert_select "[data-next-item='training-2026-11-17']", 1
      assert_select "[data-next-item='training-2026-12-17']", 1, "entra la siguiente de la fila"
    end
  end

  test "during the event week it shows the next two activities of the agenda" do
    day = Rails.configuration.x.event_start_on + 1
    [ [ "Desayuno", "07:00", "08:00" ], [ "Clases FSY", "10:00", "12:00" ], [ "Cena", "18:00", "19:00" ] ].each do |title, from, to|
      Activity.create!(title: title, category: :comida, location: "Comedores",
                       date: day.to_s, start_time: from, end_time: to)
    end

    travel_to Time.zone.local(day.year, day.month, day.day, 6) do
      get dashboard_path

      assert_select "[data-next-item^='activity-']", 2, "durante la semana manda la agenda"
      assert_select "[data-next-up]", text: /Desayuno/
      assert_select "[data-next-up]", text: /Clases FSY/
      assert_select "[data-next-up]", { text: /Cena/, count: 0 }, "solo las dos próximas"
      assert_select "[data-next-item='event']", 0
    end
  end

  test "kitchen and infirmary see what each ficha needs, ignoring the ninguna answers" do
    participants(:juan).update!(allergies: "Maní", diet: "Sin restricciones", medicines: "Ninguna")
    participants(:maria).update!(rol: :joven, allergies: "Ninguna", diet: "Vegetariana")

    get dashboard_path

    assert_select "[data-care-count='allergies']", text: "1"
    assert_select "[data-care-count='diet']", { text: "1" }, "«Sin restricciones» no cuenta como dieta especial"
    assert_select "[data-care-count='medicines']", text: "0"
  end

  test "the totals and the kitchen figures are doors into their lists" do
    get dashboard_path

    assert_select "a[data-kpi-link='total_jovenes'][href='#{participants_path}']"
    assert_select "a[data-kpi-link='total_staff'][href='#{staff_participants_path}']"
    Participant::CARE_FILTERS.each_key do |care|
      assert_select "a[data-care-link='#{care}'][href='#{participants_path(care: care)}']"
    end
  end

  test "a consejero sees the agenda card but not the kitchen one" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get dashboard_path

    assert_response :success
    assert_select "[data-care]", 0
    assert_select "[data-next-up]", 1, "la agenda sí la ve todo el mundo"
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
