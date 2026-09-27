require "test_helper"

class TrainingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @past = Training.create!(name: "Primera", held_on: 1.week.ago.to_date)
    @next_one = Training.create!(name: "Segunda", held_on: 3.weeks.from_now.to_date)
    @counselor = participants(:maria)
    @logistics = Participant.create!(first_name: "Luis", last_name: "Mena", age: 30, stake: "las_americas",
                                     shirt_number: "l", gender: "H", rol: :logistica)
  end

  test "the summary lives in the agenda and counts each training" do
    TrainingAttendance.create!(training: @past, participant: @counselor, recorded_at: @past.held_on)

    get agenda_trainings_path

    assert_response :success
    assert_select "[data-training-card='#{@past.id}'] [data-training-attended]", text: /1/
    assert_select "a[href='#{agenda_training_path(@past)}']"
    assert_select "[data-staff-row='#{@counselor.id}'] [data-mark='yes']", 1
    assert_select "[data-staff-row='#{@logistics.id}'] [data-mark='no']", 1, "quien no vino a una que ya pasó, faltó"
    assert_select "[data-staff-row='#{@counselor.id}'] [data-mark='pending']", 1, "la que no llega todavía no se juzga"
  end

  test "the table says how many of the held trainings each one attended" do
    TrainingAttendance.create!(training: @past, participant: @counselor, recorded_at: @past.held_on)

    get agenda_trainings_path

    assert_select "[data-staff-row='#{@counselor.id}'] [data-attendance-total]", text: "1 de 1"
    assert_select "[data-staff-row='#{@logistics.id}'] [data-attendance-total]", text: "0 de 1"
  end

  test "a training page separates who came from who did not" do
    TrainingAttendance.create!(training: @past, participant: @counselor, recorded_at: @past.held_on)

    get agenda_training_path(@past)

    assert_response :success
    assert_select "[data-figure='asistieron']", text: "1"
    assert_select "[data-attendees]", text: /#{@counselor.full_name}/
    assert_select "[data-absentees]", text: /#{@logistics.full_name}/
  end

  test "a training that has not happened yet counts pending, not absent" do
    get agenda_training_path(@next_one)

    assert_select "[data-figure='pendientes']", text: Training.expected.count.to_s
    assert_select "[data-figure='faltaron']", 0
    assert_select "h2", text: /Por registrar/
  end

  test "marking from the training page repaints only the roster" do
    post agenda_training_attendances_path(@past, participant_id: @logistics.id), as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action='replace'][target='training-roster']"
    assert_select "[data-attendees] .roster-moved", text: /#{@logistics.full_name}/
  end

  test "the breakdown groups the roles that matter" do
    TrainingAttendance.create!(training: @past, participant: @counselor, recorded_at: @past.held_on)

    get agenda_training_path(@past)

    assert_select "[data-role-row='consejeros']", text: /1 de 1/
    assert_select "[data-role-row='logistica']", text: /0 de 1/
  end

  test "marking by hand adds the attendance and says who did it" do
    assert_difference -> { @past.attendances.count }, 1 do
      post agenda_training_attendances_path(@past, participant_id: @logistics.id)
    end

    attendance = @past.attendances.last
    assert attendance.source_manual?
    assert_equal "Administrador del sistema", attendance.recorded_by_name
    assert_match(/quedó marcado/, flash[:notice])
  end

  test "marking twice says it was already there instead of failing" do
    post agenda_training_attendances_path(@past, participant_id: @logistics.id)

    assert_no_difference -> { @past.attendances.count } do
      post agenda_training_attendances_path(@past, participant_id: @logistics.id)
    end
    assert_match(/ya estaba/, flash[:notice])
  end

  test "an attendance marked by mistake can be removed" do
    attendance = TrainingAttendance.create!(training: @past, participant: @counselor, recorded_at: @past.held_on)

    assert_difference -> { @past.attendances.count }, -1 do
      delete agenda_training_attendance_path(@past, attendance)
    end
  end

  test "any staff member sees the summary, but only the committee marks" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: @counselor))

    get agenda_trainings_path
    assert_response :success

    assert_no_difference -> { @past.attendances.count } do
      post agenda_training_attendances_path(@past, participant_id: @logistics.id)
    end
    assert_redirected_to dashboard_path
  end

  test "the attendance PDF comes out with a column per training" do
    get trainings_reports_path

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF-")
    assert_match(/filename="capacitaciones-/, response.headers["Content-Disposition"])
  end

  test "the profile shows which trainings each staff member attended" do
    TrainingAttendance.create!(training: @past, participant: @counselor, recorded_at: @past.held_on)

    get participant_path(@counselor)

    assert_select "[data-trainings-card]", 1
    assert_select "[data-training-mark='asistió']", 1
    assert_select "[data-training-mark='pendiente']", 1
  end

  test "a joven has no trainings card: the trainings are for staff" do
    get participant_path(participants(:juan))

    assert_select "[data-trainings-card]", 0
  end
end
