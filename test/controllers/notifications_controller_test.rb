require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "shows an honest empty state instead of sample notifications" do
    get notifications_path

    assert_response :success
    assert_select "[data-empty-state='notifications']", text: /No tienes notificaciones/
    refute_includes response.body, "Has recibido una nueva asignación"
  end

  test "every page has a bell with an empty dropdown and no unread badge" do
    get dashboard_path

    assert_select "button[data-notifications-trigger]"
    assert_select "[data-dropdown-target='menu'] [data-empty-state='notifications']"
    assert_select "a[href='#{notifications_path}'][aria-label='Notificaciones']"
    assert_select "[data-unread-badge]", count: 0
  end
end
