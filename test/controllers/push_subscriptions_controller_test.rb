require "test_helper"

class PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  SUBSCRIPTION = {
    endpoint: "https://fcm.googleapis.com/fcm/send/abc123",
    keys: { p256dh: "BLlave-publica-del-navegador", auth: "secreto-corto" }
  }.freeze

  test "a browser registers the device and it belongs to whoever is signed in" do
    assert_difference -> { PushSubscription.count }, 1 do
      post push_subscription_notifications_path, params: { subscription: SUBSCRIPTION }, as: :json
    end

    assert_response :created
    subscription = PushSubscription.last
    assert_equal users(:one), subscription.user
    assert_equal SUBSCRIPTION[:endpoint], subscription.endpoint
    assert subscription.last_used_at.present?
  end

  test "registering twice from the same device updates instead of duplicating" do
    post push_subscription_notifications_path, params: { subscription: SUBSCRIPTION }, as: :json

    assert_no_difference -> { PushSubscription.count } do
      post push_subscription_notifications_path, params: { subscription: SUBSCRIPTION }, as: :json
    end
  end

  test "an incomplete subscription is rejected, not half saved" do
    assert_no_difference -> { PushSubscription.count } do
      post push_subscription_notifications_path,
           params: { subscription: { endpoint: "https://example.com/x", keys: {} } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "turning notifications off removes only that device" do
    post push_subscription_notifications_path, params: { subscription: SUBSCRIPTION }, as: :json
    other = PushSubscription.create!(user: users(:one), endpoint: "https://example.com/otro",
                                     p256dh_key: "k", auth_key: "a")

    assert_difference -> { PushSubscription.count }, -1 do
      delete suscripcion_notifications_path(endpoint: SUBSCRIPTION[:endpoint])
    end

    assert_response :no_content
    assert PushSubscription.exists?(other.id)
  end

  test "signing out is enough: no session, no subscriptions" do
    sign_out

    post push_subscription_notifications_path, params: { subscription: SUBSCRIPTION }, as: :json

    assert_response :redirect
    assert_equal 0, PushSubscription.count
  end

  test "the settings test sends a real push to this device and says it went out" do
    post push_subscription_notifications_path, params: { subscription: SUBSCRIPTION }, as: :json
    sent = []

    stubbing_push(->(**options) { sent << options }) do
      post push_test_notifications_path, params: { endpoint: SUBSCRIPTION[:endpoint] }, as: :json
    end

    assert_response :success
    assert_equal [ SUBSCRIPTION[:endpoint] ], sent.map { |options| options[:endpoint] }
    assert_equal "high", sent.first[:urgency]
    assert_equal "Prueba de notificaciones", JSON.parse(sent.first[:message])["title"]
  end

  test "the settings test tells what the push service answered when it fails" do
    post push_subscription_notifications_path, params: { subscription: SUBSCRIPTION }, as: :json
    refused = WebPush::Unauthorized.new(Struct.new(:code, :body).new("403", "BadJwtToken"), "push.example.com")

    stubbing_push(->(**) { raise refused }) do
      post push_test_notifications_path, params: { endpoint: SUBSCRIPTION[:endpoint] }, as: :json
    end

    assert_response :bad_gateway
    assert_match "BadJwtToken", response.parsed_body["error"]
  end

  test "the settings test only reaches the signed-in person's own device" do
    other = User.create!(email_address: "otra@example.com", password: "Password-largo-123", superadmin: true)
    PushSubscription.create!(user: other, endpoint: "https://example.com/ajeno", p256dh_key: "k", auth_key: "a")

    stubbing_push(->(**) { flunk "no push should go out" }) do
      post push_test_notifications_path, params: { endpoint: "https://example.com/ajeno" }, as: :json
    end

    assert_response :not_found
  end

  test "the service worker re-registers by itself, with the header that lets it in without the CSRF token" do
    get pwa_service_worker_path(format: :js)

    assert_response :success
    assert_includes response.body, '"X-Service-Worker": "1"'
    assert_includes response.body, Rails.application.credentials.dig(:vapid, :public_key).to_s
  end

  private
    def stubbing_push(behaviour)
      original = WebPush.method(:payload_send)
      WebPush.define_singleton_method(:payload_send) { |**options| behaviour.call(**options) }
      yield
    ensure
      WebPush.singleton_class.send(:define_method, :payload_send, original)
    end
end
