require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @company = Company.create!(number: 3)
    participants(:juan).update!(company: @company, room: "204")
    Activity.create!(title: "Devocional", category: :devocional, location: "Auditorio",
                     date: Rails.configuration.x.event_start_on.to_s, start_time: "19:00", end_time: "20:30")
  end

  test "the index lists the printable reports and the bulk upload" do
    get reports_path

    assert_response :success
    assert_select "a[href='#{participants_reports_path}']"
    assert_select "a[href='#{participants_reports_path(scope: 'mujeres')}']"
    assert_select "a[href='#{rooms_reports_path}']"
    assert_select "a[href='#{agenda_reports_path}']"
    assert_select "a[href='#{new_participant_import_path}']"
  end

  test "each report renders a real PDF" do
    { participants_reports_path => "participantes",
      participants_reports_path(scope: "mujeres") => "participantes-mujeres",
      participants_reports_path(scope: "staff") => "staff",
      rooms_reports_path => "cuartos",
      agenda_reports_path => "agenda" }.each do |path, stem|
      get path

      assert_response :success
      assert_equal "application/pdf", response.media_type
      assert response.body.start_with?("%PDF-"), "#{path} no devolvió un PDF"
      assert_match(/filename="#{stem}-\d{4}-\d{2}-\d{2}\.pdf"/, response.headers["Content-Disposition"])
    end
  end

  test "an unknown scope falls back to the full list instead of failing" do
    get participants_reports_path(scope: "inventado")

    assert_response :success
    assert_match(/filename="participantes-/, response.headers["Content-Disposition"])
  end

  test "the logistics director only sees the logistics section" do
    director = Participant.create!(first_name: "Luis", last_name: "Logística", age: 40, stake: "las_americas",
                                   shirt_number: "l", gender: "H", rol: :director_logistica)
    sign_in_as(User.create!(email_address: "logistica@fsy.com", password: "Logistica1!", participant: director))

    get reports_path
    assert_response :success
    assert_select "a[href='#{participants_reports_path}']", false
    assert_select "a[href='#{new_participant_import_path}']", false
    assert_select "a[href='#{inventory_reports_path}']", text: /Generar PDF/
    assert_select "a[href='#{labels_reports_path}']"

    get participants_reports_path
    assert_redirected_to reports_path
  end

  test "a consejero cannot reach the reports at all" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get reports_path
    assert_redirected_to dashboard_path

    get rooms_reports_path
    assert_redirected_to dashboard_path
  end
end
