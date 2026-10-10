require "test_helper"

# La hoja de instalar no viaja con cada página: install_controller.js la pide a /instalar-app al abrirla.
class InstallSheetsControllerTest < ActionDispatch::IntegrationTest
  test "the pages carry only the empty holder, not the sheet" do
    sign_in_as(users(:one))
    get dashboard_path

    assert_select "[data-controller='install'][data-install-url-value='#{install_sheet_path}']"
    assert_select "[data-install-target='sheet']", count: 0
  end

  test "the sheet is served on its own, also before signing in" do
    get install_sheet_path

    assert_response :success
    assert_select "dialog[data-install-target='sheet']"
    assert_select "[data-install-panel]", minimum: 4
    assert_no_match(/<html/, response.body, "solo la hoja, sin el layout")
  end
end
