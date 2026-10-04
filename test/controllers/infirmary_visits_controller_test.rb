require "test_helper"

class InfirmaryVisitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @branch = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 3, auxiliar_company: @branch)
    @other = Company.create!(number: 4)
    @juan = participants(:juan).tap { |joven| joven.update!(company: @company, allergies: "Penicilina") }
    @pedro = person("Pedro", "joven", "H", company: @other)

    @counselor = person("Carlos", "consejero", "H")
    @company.memberships.create!(participant: @counselor)
    @auxiliar = person("Laura", "auxiliar", "M")
    @branch.memberships.create!(participant: @auxiliar)
    @nurse = person("Patricia", "logistica", "M", logistics_area: LogisticsArea.create!(name: "Enfermería", nursing: true))
    @registrar = person("Rita", "registrador", "M")
    @director = person("Dir", "director", "H")
  end

  test "all the staff sees the board; jovenes don't" do
    InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "fiebre", detail: "38.4 y dolor de garganta").start
    sign_in_as account(@registrar)

    get infirmary_visits_path
    assert_response :success
    assert_select "[data-infirmary-visit='#{@juan.id}'][data-infirmary-status=adentro]", text: /Fiebre/
    assert_select "[data-infirmary-visit='#{@juan.id}'] [data-infirmary-flag=allergies]", text: /Penicilina/
    assert_select "[data-infirmary-detail]", 0, "the detail is only for those who read the chart"
    assert_select "[data-infirmary-action]", 0, "a registrar neither admits nor discharges"
    assert_select "nav a[href='#{infirmary_visits_path}']", text: /Enfermería/

    sign_out
    sign_in_as account(@pedro)
    get infirmary_visits_path
    assert_redirected_to dashboard_path
  end

  test "a counselor only announces their own jovenes, and nursing confirms the arrival" do
    sign_in_as account(@counselor)

    get new_infirmary_visit_path(q: "juan perez")
    assert_select "[data-infirmary-result='#{@juan.id}']"
    get new_infirmary_visit_path(q: "pedro")
    assert_select "[data-infirmary-no-results]"

    assert_no_difference -> { Alert.count } do
      post infirmary_visits_path(participant_id: @juan.id), params: { infirmary_visit: { reason: "malestar", reason_detail: "Mareo" } }
    end
    visit = InfirmaryVisit.last
    assert_redirected_to infirmary_chart_path(@juan)
    assert visit.en_camino?
    assert_equal "Carlos Prueba", visit.announced_by_name
    assert_equal "Avisó que lleva a Juan Pérez a enfermería (malestar)", AuditLog.enfermeria.last.summary

    assert_no_difference -> { InfirmaryVisit.count } do
      post infirmary_visits_path(participant_id: @pedro.id), params: { infirmary_visit: { reason: "fiebre" } }
    end
    patch admit_infirmary_visit_path(visit)
    assert visit.reload.en_camino?, "a counselor can't confirm their own notice"

    sign_out
    sign_in_as account(@nurse)
    get infirmary_visits_path
    assert_select "[data-infirmary-visit='#{@juan.id}'][data-infirmary-status=en_camino] [data-infirmary-action=confirmar]"
    assert_difference -> { Alert.count }, 1 do
      patch admit_infirmary_visit_path(visit)
    end
    assert visit.reload.adentro?
    assert_equal [ @counselor.id, @auxiliar.id ].sort, Alert.last.recipient_ids.sort
  end

  test "the counselor can take back a notice that hasn't arrived" do
    visit = InfirmaryVisit.announce(@juan, by: @counselor, reason: "fiebre").tap(&:start)
    sign_in_as account(@counselor)

    delete infirmary_visit_path(visit)
    assert_redirected_to infirmary_visits_path
    assert_not InfirmaryVisit.exists?(visit.id)
  end

  test "nursing admits, writes the chart and discharges" do
    sign_in_as account(@nurse)

    post infirmary_visits_path(participant_id: @pedro.id), params: { infirmary_visit: { reason: "lesion", reason_detail: "Tobillo" } }
    visit = InfirmaryVisit.last
    assert visit.adentro?
    assert_equal "Patricia Prueba", visit.admitted_by_name

    post infirmary_visit_notes_path(visit), params: { infirmary_note: { temperature: "37.2", heart_rate: "88" } }
    assert_redirected_to infirmary_chart_path(@pedro, anchor: "visita-#{visit.id}")
    assert_equal({ "temperature" => "37.2", "heart_rate" => "88" }, visit.notes.last.vitals)

    post infirmary_visit_notes_path(visit), params: { infirmary_note: { body: " " } }
    assert_response :unprocessable_entity
    assert_select "[data-infirmary-note-errors]", text: /escribe la nota o anota algún signo vital/

    patch discharge_infirmary_visit_path(visit), params: { disposition: "regreso", discharge_notes: "Hielo cada 2 horas" }
    assert visit.reload.alta?
    assert_equal "Dio de alta a Pedro Prueba de enfermería: volvió a su compañía", AuditLog.enfermeria.last.summary
  end

  test "the clinical notes are read by nursing, the joven's carers and the director, not by the rest of the staff" do
    visit = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "fiebre", detail: "Garganta roja").tap(&:start)
    visit.notes.create!(body: "Acetaminofén 500 mg", author: @nurse, author_name: "Patricia Prueba")

    [ @counselor, @auxiliar, @director, @nurse ].each do |reader|
      sign_in_as account(reader)
      get infirmary_chart_path(@juan)
      assert_select "[data-infirmary-note]", { text: /Acetaminofén/ }, "#{reader.role_label} reads the notes"
      sign_out
    end

    sign_in_as account(@registrar)
    get infirmary_chart_path(@juan)
    assert_response :success
    assert_select "[data-infirmary-notes-locked]"
    assert_no_match(/Acetaminofén|Garganta roja/, response.body)
  end

  test "only nursing writes the chart" do
    visit = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "fiebre").tap(&:start)
    sign_in_as account(@counselor)

    assert_no_difference -> { InfirmaryNote.count } do
      post infirmary_visit_notes_path(visit), params: { infirmary_note: { body: "Hola" } }
    end
    patch discharge_infirmary_visit_path(visit), params: { disposition: "casa" }
    assert visit.reload.adentro?
  end

  test "night attendance marks who is still in the infirmary as absent" do
    InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "fiebre").start
    sign_in_as account(@counselor)

    get company_night_attendance_path(@company, genero: "H")
    assert_select "[data-night-joven='#{@juan.id}'][data-night-infirmary][data-state=ausente]"
    assert_select "[data-night-joven='#{@juan.id}'] input[name='marks[#{@juan.id}][absence_reason]'][value=enfermeria]"
  end

  private
    def person(name, rol, gender, **attrs)
      Participant.create!(first_name: name, last_name: "Prueba", age: 30, stake: "bello_horizonte", ward: "ducuali",
                          shirt_number: "m", gender: gender, rol: rol, **attrs)
    end

    def account(participant)
      User.create!(email_address: "#{participant.first_name.downcase}@fsy.com", password: "Prueba123!", participant: participant)
    end
end
