require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @activity = Activity.create!(title: "Servicio comunitario", category: :servicio, location: "La Rotonda",
                                 date: (Rails.configuration.x.event_start_on + 1).to_s, start_time: "10:00", end_time: "12:30")
    @joven = participants(:juan)
  end

  test "assigning an agenda activity shows it on the profile and records it" do
    assert_difference -> { Assignment.count }, 1 do
      post participant_assignments_path(@joven), params: { assignment: { activity_id: @activity.id, details: "Lleva gorra" } }
    end

    assert_redirected_to participant_path(@joven)
    assert_equal "Asignó «Servicio comunitario» a Juan Pérez", AuditLog.asignaciones.recent.first.summary

    alert = Alert.recent.first
    assert alert.audience_individual?, "the alert goes to that person only"
    assert_equal @joven, alert.recipient
    assert alert.source_asignacion?
    assert_equal "Nueva asignación: Servicio comunitario", alert.title

    get participant_path(@joven)
    assert_select "[data-assignments] [data-assignment-id]", 1
    assert_select "[data-assignments]", text: /Servicio comunitario/
    assert_select "[data-assignments]", text: /Martes 12 de enero/
  end

  test "an assignment outside the agenda keeps its own title, time and place" do
    post participant_assignments_path(@joven), params: {
      assignment: { title: "Primera oración", starts_at: "#{Rails.configuration.x.event_start_on}T06:30", location: "Auditorio", status: "confirmada" }
    }

    assignment = Assignment.last
    assert_not assignment.from_agenda?
    assert assignment.status_confirmada?

    get participant_path(@joven)
    assert_select "[data-assignments]", text: /Primera oración/
    assert_select "[data-assignment-status]", text: "Confirmada"
  end

  test "an assignment without an activity or a title is rejected" do
    assert_no_difference -> { Assignment.count } do
      post participant_assignments_path(@joven), params: { assignment: { details: "Sin título" } }
    end

    assert_response :unprocessable_entity
  end

  test "the status moves forward and the assignment can be removed" do
    post participant_assignments_path(@joven), params: { assignment: { activity_id: @activity.id } }
    assignment = Assignment.last

    patch assignment_path(assignment, assignment: { status: "confirmada" })
    assert assignment.reload.status_confirmada?

    assert_difference -> { Assignment.count }, -1 do
      delete assignment_path(assignment)
    end
    assert_equal "Quitó «Servicio comunitario» de Juan Pérez", AuditLog.asignaciones.recent.first.summary
  end

  test "a counselor assigns within their own company but not outside it" do
    company = Company.create!(number: 1)
    company.memberships.create!(participant: participants(:maria))
    @joven.update!(company: company)
    outsider = Participant.create!(first_name: "Ana", last_name: "Fuera", age: 15, stake: "villa_flor",
                                   shirt_number: "s", gender: "M", rol: "joven")

    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    assert_difference -> { Assignment.count }, 1 do
      post participant_assignments_path(@joven), params: { assignment: { activity_id: @activity.id } }
    end

    assert_no_difference -> { Assignment.count } do
      post participant_assignments_path(outsider), params: { assignment: { activity_id: @activity.id } }
    end
    assert_redirected_to participant_path(outsider)
  end

  test "a joven sees their assignments but gets no buttons" do
    post participant_assignments_path(@joven), params: { assignment: { activity_id: @activity.id } }

    sign_out
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: @joven))

    get myprofile_participants_path
    assert_response :success
    assert_select "[data-assignments]", text: /Servicio comunitario/
    assert_select "a[href='#{new_participant_assignment_path(@joven)}']", 0

    get notifications_path
    assert_select "main [data-alert-id]", 1, "the assignment alert reaches them"
  end
end
