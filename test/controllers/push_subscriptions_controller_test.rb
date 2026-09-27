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
end
