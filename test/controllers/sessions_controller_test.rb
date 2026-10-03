require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to dashboard_url
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "an account whose ficha is gone cannot sign in, even with the right password" do
    orphan = User.create!(email_address: "huerfano@fsy.com", password: "Password123!")

    post session_path, params: { email_address: orphan.email_address, password: "Password123!" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
    assert LoginAttempt.recent.first.result_failed?
  end

  test "an open session of an account that lost its ficha is closed" do
    user = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    sign_in_as(user)
    user.update_column(:participant_id, nil)

    get dashboard_path

    assert_redirected_to new_session_path
    assert_not Session.exists?(user_id: user.id)
  end

  test "a session in daily use still ends after Session::MAX_AGE" do
    sign_in_as(@user)
    Current.session.update_columns(created_at: (Session::MAX_AGE + 1.day).ago, updated_at: 1.minute.ago)

    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "passwords and emails never reach the logs" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filtered = filter.filter("email_address" => "a@b.com", "password" => "x", "password_confirmation" => "x", "password_challenge" => "x")

    assert filtered.values.all?("[FILTERED]"), filtered.inspect
  end
end
