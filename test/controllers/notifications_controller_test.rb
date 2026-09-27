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

  test "the bell asks for its number and gets what is really pending" do
    Alert.create!(title: "Una", body: "Texto", sender_name: "Marta", audience: :todos)
    Alert.create!(title: "Otra", body: "Texto", sender_name: "Marta", audience: :todos)

    get count_notifications_path, headers: { "Accept" => "application/json" }

    assert_response :success
    assert_equal 2, response.parsed_body["unread"]
  end

  test "after opening the list the number is zero, which is what the cached page gets wrong" do
    Alert.create!(title: "Una", body: "Texto", sender_name: "Marta", audience: :todos)

    get notifications_path
    get count_notifications_path, headers: { "Accept" => "application/json" }

    assert_equal 0, response.parsed_body["unread"], "abrir la lista deja la campanita en cero"
  end

  test "explains the empty state when there are no alerts" do
    get notifications_path

    assert_response :success
    assert_select "[data-empty-state='notifications']"
  end
end
