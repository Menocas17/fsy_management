require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "lists the alerts the signed-in person can see" do
    Alert.create!(title: "Bienvenida", body: "Nos vemos en el auditorio.", sender_name: "Marta", audience: :todos)

    get notifications_path

    assert_response :success
    assert_select "main [data-alert-id]", 1, "the bell in the top bar renders the same alerts, so only count the page"
    assert_select "[data-page-header] h1", "Notificaciones"
  end

  test "explains the empty state when there are no alerts" do
    get notifications_path

    assert_response :success
    assert_select "[data-empty-state='notifications']"
  end
end
