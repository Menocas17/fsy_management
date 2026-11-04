require "test_helper"

class ReservesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(number: 1)
    @counselor = participants(:maria)
    @counselor.update!(company: @company, room: "101")
  end

  test "full access moves a counselor to the reserve: it leaves its company and every list" do
    sign_in_as(users(:one))
    get edit_participant_path(@counselor)
    assert_select "form[data-turbo-confirm-button='Sí, archivar'] [data-reserve-participant='#{@counselor.id}']"

    assert_difference -> { AuditLog.where(category: :participantes, action: "reserved").count }, 1 do
      post reserves_path, params: { participant_id: @counselor.id }
    end
    assert_redirected_to reserves_path

    reserved = Participant.in_reserve.find(@counselor.id)
    assert_nil reserved.company_id
    assert_nil reserved.room
    assert_empty Membership.where(participant_id: @counselor.id)
    assert_nil Participant.find_by(id: @counselor.id)
    assert_not_includes Participant.staff, reserved
    assert_equal 0, Participant.where(rol: :consejero).count

    get reserves_path
    assert_select "[data-reserve-row='#{@counselor.id}']", text: /María García/
    assert_select "form[data-turbo-confirm-button='Sí, devolver'] [data-reserve-restore='#{@counselor.id}']"
    assert_select "form[data-turbo-confirm-button='Sí, borrar'] [data-reserve-destroy='#{@counselor.id}']"

    get staff_participants_path
    assert_response :success
    assert_no_match "María García", response.body

    get participant_path(@counselor)
    assert_response :not_found
  end

  test "only counselors go to the reserve" do
    sign_in_as(users(:one))
    post reserves_path, params: { participant_id: participants(:juan).id }

    assert_redirected_to participant_path(participants(:juan))
    assert_nil participants(:juan).reload.reserved_at
  end

  test "a counselor back from the reserve returns without company" do
    @counselor.reserve!
    sign_in_as(users(:one))

    patch restore_reserve_path(@counselor)
    assert_redirected_to participant_path(@counselor)
    assert_nil @counselor.reload.reserved_at
    assert_includes Participant.counselors, @counselor
    assert_nil @counselor.company_id
  end

  test "from the reserve a counselor is deleted for good, with its account" do
    user = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: @counselor)
    @counselor.reserve!
    sign_in_as(users(:one))

    assert_difference -> { Participant.unscoped.count } => -1, -> { User.count } => -1 do
      delete reserve_path(@counselor)
    end
    assert_redirected_to reserves_path
    assert_not User.exists?(user.id)
  end

  test "a participant outside the reserve can't be deleted from it" do
    sign_in_as(users(:one))
    delete reserve_path(@counselor)

    assert_response :not_found
    assert Participant.exists?(@counselor.id)
  end

  test "a counselor in the reserve can't sign in and its open sessions end" do
    user = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: @counselor)
    sign_in_as(user)
    get dashboard_path
    assert_response :success

    @counselor.reserve!
    get dashboard_path
    assert_redirected_to new_session_path

    assert_empty user.sessions.reload
    assert_no_difference -> { Session.count } do
      post session_path, params: { email_address: "maria@fsy.com", password: "Consejera1!" }
    end
    assert_redirected_to new_session_path
  end

  test "without full access there is no reserve" do
    coordinator = participants(:juan).dup
    coordinator.update!(rol: :auxiliar, first_name: "Luis")
    sign_in_as(User.create!(email_address: "luis@fsy.com", password: "Auxiliar1!", participant: coordinator))

    get reserves_path
    assert_redirected_to dashboard_path
    post reserves_path, params: { participant_id: @counselor.id }
    assert_nil @counselor.reload.reserved_at

    get dashboard_path
    assert_select "a[href='#{reserves_path}']", false
  end

  test "full access finds Reserva in the menu" do
    sign_in_as(users(:one))
    get dashboard_path

    assert_select "a[href='#{reserves_path}']"
  end
end
