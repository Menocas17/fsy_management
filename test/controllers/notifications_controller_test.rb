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

  test "opening the bell's menu marks everything as read" do
    Alert.create!(title: "Una", body: "Texto", sender_name: "Marta", audience: :todos)

    patch read_notifications_path

    assert_response :no_content
    assert_equal 0, users(:one).reload.unread_alerts_count
  end

  test "the bell's menu carries the address that marks it read" do
    Alert.create!(title: "Una", body: "Texto", sender_name: "Marta", audience: :todos)

    get notifications_path

    assert_select "[data-alert-chime-read-url-value='#{read_notifications_path}']"
    assert_select "[data-action*='alert-chime#markRead']"
  end

  test "the bell's menu brings the latest alerts in its own frame, so no other page pays for them" do
    Alert.create!(title: "Bienvenida", body: "Nos vemos en el auditorio.", sender_name: "Marta", audience: :todos)

    get menu_notifications_path

    assert_response :success
    assert_select "turbo-frame#notifications_menu[target='_top'] [data-alert-id]", 1
    assert_select "turbo-frame#notifications_menu", text: /Bienvenida/
    assert_select "[data-alerts-list]"
  end

  test "the bell's menu says so when there is nothing" do
    get menu_notifications_path

    assert_select "turbo-frame#notifications_menu [data-empty-state='notifications']"
  end

  test "explains the empty state when there are no alerts" do
    get notifications_path

    assert_response :success
    assert_select "[data-empty-state='notifications']"
  end

  test "each alert opens what it announces, or itself when it points nowhere" do
    plain = Alert.create!(title: "Bienvenida", body: "Texto", sender_name: "Marta", audience: :todos)
    linked = Alert.create!(title: "Gasto", body: "Texto", sender_name: "Finanzas", audience: :todos, link_path: "/finanzas")

    get notifications_path

    assert_select "main [data-alert-id='#{plain.id}'] a[data-alert-open][href='#{alert_path(plain)}']", "Bienvenida"
    assert_select "main [data-alert-id='#{linked.id}'] a[data-alert-open][href='/finanzas']", "Gasto"
  end

  test "deleting an alert hides it only for whoever deleted it" do
    alert = Alert.create!(title: "Bienvenida", body: "Texto", sender_name: "Marta", audience: :todos)
    other = User.create!(email_address: "otra@fsy.com", password: "Password1!", participant: participants(:maria))

    delete notification_path(alert), as: :turbo_stream

    assert_response :success
    assert_match "remove", response.body
    assert Alert.exists?(alert.id), "la alerta sigue existiendo para los demás"
    assert_not_includes Alert.inbox_for(users(:one)), alert
    assert_includes Alert.inbox_for(other), alert

    get notifications_path
    assert_select "main [data-alert-id]", 0
    assert_select "[data-empty-state='notifications']"
  end

  test "deleting an unread alert takes it off the bell's count" do
    alert = Alert.create!(title: "Una", body: "Texto", sender_name: "Marta", audience: :todos)
    Alert.create!(title: "Otra", body: "Texto", sender_name: "Marta", audience: :todos)

    delete notification_path(alert), as: :turbo_stream
    get count_notifications_path, headers: { "Accept" => "application/json" }

    assert_equal 1, response.parsed_body["unread"]
  end

  test "an alert meant for someone else can't be deleted from here" do
    staff_only = Alert.create!(title: "Solo directores", body: "Texto", sender_name: "Marta", audience: :por_roles, target_roles: [ "director" ])
    sign_in_as(User.create!(email_address: "joven@fsy.com", password: "Password1!", participant: participants(:juan)))

    delete notification_path(staff_only), as: :turbo_stream

    assert_response :not_found
    assert_equal 0, AlertDismissal.count
  end

  test "clearing everything empties the list, and later alerts still arrive" do
    Alert.create!(title: "Una", body: "Texto", sender_name: "Marta", audience: :todos, created_at: 1.minute.ago)
    Alert.create!(title: "Otra", body: "Texto", sender_name: "Marta", audience: :todos, created_at: 1.minute.ago)

    delete clear_notifications_path, as: :turbo_stream
    assert_response :success
    assert_empty Alert.inbox_for(users(:one).reload)

    Alert.create!(title: "Nueva", body: "Texto", sender_name: "Marta", audience: :todos)
    get notifications_path
    assert_select "main [data-alert-id]", 1
    assert_select "main [data-alert-id]", text: /Nueva/
  end
end
