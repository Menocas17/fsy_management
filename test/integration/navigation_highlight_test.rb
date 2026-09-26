require "test_helper"

# Creating or editing something should keep its section highlighted in the sidebar.
class NavigationHighlightTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @participant = participants(:juan)
    @company = Company.create!(number: 1)
    @activity = Activity.create!(title: "Servicio comunitario", category: :servicio,
                                 date: Rails.configuration.x.event_start_on.to_s, start_time: "10:00", end_time: "12:30")
    @alert = Alert.create!(title: "Aviso", body: "Texto", sender_name: "Marta", audience: :todos)
  end

  test "every list, form and detail page highlights its own section" do
    {
      participants_path => "Jóvenes",
      new_participant_path => "Jóvenes",
      edit_participant_path(@participant) => "Jóvenes",
      participant_path(@participant) => "Jóvenes",
      staff_participants_path => "Staff",
      edit_participant_path(@participant, from: "staff") => "Staff",
      companies_path => "Compañías",
      new_company_path => "Compañías",
      edit_company_path(@company) => "Compañías",
      auxiliar_companies_path => "Compañías",
      new_auxiliar_company_path => "Compañías",
      organigrama_path => "Organigrama",
      agenda_path => "Agenda",
      new_activity_path => "Agenda",
      edit_activity_path(@activity) => "Agenda",
      alerts_path => "Alertas",
      new_alert_path => "Alertas",
      alert_path(@alert) => "Alertas",
      audit_logs_path => "Historial"
    }.each do |path, expected|
      get path

      assert_response :success, path
      highlighted = css_select("aside a[aria-current='page']").map { |link| link.text.strip }
      assert_equal [ expected ], highlighted, "#{path} should highlight #{expected}"
    end
  end

  test "detail pages carry a way back in the top bar" do
    {
      participant_path(@participant) => "Jóvenes",
      participant_path(@participant, from: "staff") => "Staff",
      new_participant_path => "Jóvenes",
      company_path(@company) => "Compañías",
      edit_company_path(@company) => @company.name,
      new_activity_path => "Agenda",
      edit_activity_path(@activity) => "Agenda",
      alert_path(@alert) => "Alertas",
      settings_path => "Inicio"
    }.each do |path, label|
      get path

      assert_response :success, path
      assert_select "[data-page-back] a", { text: /#{Regexp.escape(label)}/, count: 1 }, "#{path} debería ofrecer volver a #{label}"
    end
  end

  test "the lists in the sidebar need no way back" do
    [ dashboard_path, participants_path, companies_path, agenda_path ].each do |path|
      get path

      assert_select "[data-page-back]", { count: 0 }, "#{path} ya está en el menú lateral"
    end
  end

  test "pages outside the sidebar highlight nothing" do
    get myprofile_participants_path

    assert_response :success
    assert_empty css_select("aside a[aria-current='page']")
  end
end
