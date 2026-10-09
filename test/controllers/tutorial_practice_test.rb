require "test_helper"

# Los jóvenes de práctica del tutorial solo existen con ?practica=1 en la compañía de quien lo hace; nada de
# lo practicado se guarda, ni con ellos ni sobre registros reales.
class TutorialPracticeTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(number: 7)
    Membership.create!(associable: @company, participant: participants(:maria))
    @counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    sign_in_as @counselor
    @sofia = Participant.practice_jovenes.first
  end

  test "practice jóvenes are invisible everywhere outside the tutorial" do
    assert_equal 4, Participant.unscoped.where(practice: true).count
    assert_not Participant.exists?(@sofia.id)
    assert_not_includes Participant.jovenes.pluck(:id), @sofia.id
    assert_nil @sofia.code, "no gastan un número de gafete"

    get company_path(@company)
    assert_select "[data-practice-jovenes]", 0
    get company_path(@company, practica: "1")
    assert_select "[data-practice-jovenes] a[href='#{participant_path(@sofia, practica: "1")}']"

    get participant_path(@sofia, practica: "1")
    assert_response :success
    assert_select "a[href='#{edit_participant_path(@sofia)}']", 0, "nadie edita uno de práctica"
  end

  test "someone outside the tutorial's companies never sees them" do
    sign_in_as User.create!(email_address: "ana@fsy.com", password: "Directora1!",
                            participant: Participant.create!(first_name: "Ana", last_name: "Ruiz", age: 40, stake: "las_americas",
                                                             shirt_number: "m", gender: "M", rol: :director))
    get company_path(@company, practica: "1")
    assert_select "[data-practice-jovenes]", 0
    get participant_path(@sofia, practica: "1")
    assert_response :not_found
  end

  test "announcing a practice joven to the infirmary saves nothing" do
    get new_infirmary_visit_path(participant_id: @sofia.id, practica: "1")
    assert_response :success
    assert_select "[data-infirmary-form]"

    assert_no_difference -> { InfirmaryVisit.count } do
      post infirmary_visits_path(participant_id: @sofia.id), params: { infirmary_visit: { reason: "fiebre" } }
    end
  end

  test "the practice Conteo lists only practice jóvenes and is never saved" do
    get company_night_attendance_path(@company, genero: "M", practica: "1")
    assert_select "[data-practice-notice]"
    assert_select "[data-night-joven='#{@sofia.id}']"

    assert_no_difference -> { NightAttendance.count } do
      patch company_night_attendance_path(@company, genero: "M", practica: "1"),
            params: { marks: { @sofia.id => { status: "presente" } } }
    end
  end

  test "anything sent marked as practice is discarded before the action runs" do
    sign_in_as users(:one)
    training = Training.create!(name: "Primera", held_on: Date.current)

    assert_no_difference -> { Training.count } do
      delete agenda_training_path(training), params: { tutorial_practice: "1" }
    end
    assert_no_difference -> { Alert.count } do
      post alerts_path, params: { tutorial_practice: "1", alert: { title: "Prueba", body: "Hola", audience: "todos", priority: "informativa" } }
    end
  end

  test "starting gives the steps and a welcome alert only for this person; finishing removes it" do
    post tutorial_path, as: :json
    assert_response :success
    ids = response.parsed_body["steps"].map { |step| step["id"] }
    assert_includes ids, "announce_form"
    assert_includes ids, "conteo_confirm"
    assert_not_includes ids, "alert_send", "una consejera no envía alertas"
    welcome = Alert.source_tutorial.sole
    assert_equal participants(:maria), welcome.recipient
    assert_not Alert.sent.exists?(welcome.id), "no sale en la lista de alertas enviadas"
    assert_equal 0, AuditLog.where(category: :alertas).count, "ni en el Historial"

    patch tutorial_path
    assert_predicate @counselor.reload.tutorial_completed_at, :present?
    assert_not Alert.source_tutorial.exists?
  end
end
