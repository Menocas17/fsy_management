require "test_helper"

class ChangelogControllerTest < ActionDispatch::IntegrationTest
  test "the account menu leads to the news page" do
    sign_in_as(users(:one))
    get changelog_path

    assert_response :success
    first = ChangelogEntry.all.first
    assert_select "article##{first.anchor}", text: /#{first.title}/
    assert_select "a[data-account-menu='changelog'][href='#{changelog_path}']"
  end
end
