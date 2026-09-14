require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "renders the hero and the headline totals" do
    get dashboard_path

    assert_response :success
    assert_select "h1", text: /Todo el registro del evento/
    assert_select "[data-kpi='total_jovenes']", text: "1"
    assert_select "[data-kpi='total_staff']", text: "1"
    assert_select "[data-kpi='total_participants']", text: "2"
  end

  test "shows the new-participant shortcut to admins" do
    get dashboard_path

    assert_select "a[href='#{new_participant_path}']", text: /Nuevo participante/
  end

  test "counts shirt sizes, defaulting missing sizes to zero" do
    get dashboard_path

    assert_select "[data-shirt-size='m']", text: "1"
    assert_select "[data-shirt-size='s']", text: "1"
    assert_select "[data-shirt-size='xl']", text: "0"
  end
end
