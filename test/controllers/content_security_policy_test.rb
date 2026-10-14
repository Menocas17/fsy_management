require "test_helper"

# Solo corren los scripts de la app: los del importmap y el del <head> llevan el nonce de la política.
class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "pages only allow the app's own scripts, with the head script carrying the nonce" do
    sign_in_as(users(:one))
    get dashboard_path

    policy = response.headers["Content-Security-Policy"]
    assert_match(/script-src 'self' 'nonce-[^']+'/, policy)
    assert_match(/object-src 'none'/, policy)

    nonce = policy[/'nonce-([^']+)'/, 1]
    scripts = Nokogiri::HTML5(response.body).css("script")
    assert_not_empty scripts
    assert scripts.all? { |script| script["src"] || script["nonce"] == nonce }, "every inline script carries the nonce"
  end
end
