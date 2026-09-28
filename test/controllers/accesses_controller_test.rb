require "test_helper"

class AccessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @counselor_user = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
  end

  test "every login attempt is recorded, never with its password" do
    post session_path, params: { email_address: "maria@fsy.com", password: "equivocada" }
    post session_path, params: { email_address: "nadie@fsy.com", password: "loquesea" }
    post session_path, params: { email_address: "maria@fsy.com", password: "Consejera1!" }

    failed, unknown, ok = LoginAttempt.order(:created_at).last(3)
    assert failed.result_failed?
    assert_equal @counselor_user, failed.user
    assert unknown.result_failed?
    assert_nil unknown.user, "a mistyped email is kept, even without an account"
    assert ok.result_success?
    refute LoginAttempt.column_names.any? { |column| column.include?("passw") }
  end

  test "Accesos is in the superadmin's account menu, not in the side menu" do
    sign_in_as(@admin)

    get dashboard_path
    assert_select "[data-account-menu='accesses'][href='#{accesses_path}']", 1
    assert_select "aside a[href='#{accesses_path}']", 0
  end

  test "the superadmin sees who is online, the open sessions and the attempts" do
    LoginAttempt.create!(email_address: "intruso@fsy.com", result: :failed, ip_address: "1.2.3.4")
    sign_in_as(@admin)

    get accesses_path

    assert_response :success
    assert_select "[data-online]", text: /admin@fsy.com/
    assert_select "[data-sessions] [data-session]", minimum: 1
    assert_select "[data-attempts] [data-attempt='failed']", text: /intruso@fsy.com/
    assert_select "[data-access-count='failed']", text: "1"
  end

  test "an open session can be closed from there" do
    other = @counselor_user.sessions.create!(user_agent: "Mozilla/5.0 (Linux; Android 14) Chrome/140.0 Mobile Safari/537.36")
    sign_in_as(@admin)

    assert_difference -> { Session.count }, -1 do
      delete access_session_path(other)
    end
    assert_redirected_to accesses_path
  end

  test "nobody else sees accesses, not even the directors" do
    sign_in_as(@counselor_user)

    get accesses_path
    assert_redirected_to dashboard_path

    get dashboard_path
    assert_select "a[href='#{accesses_path}']", 0, "neither in the side menu nor in the account menu"
  end

  test "a session unused for too long is closed instead of revived" do
    sign_in_as(@counselor_user)
    Current.session.update_columns(updated_at: (Session::IDLE_LIMIT + 1.day).ago)

    get dashboard_path

    assert_redirected_to new_session_path
    assert_not Session.exists?(Current.session.id)
  end
end
