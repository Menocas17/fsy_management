require "test_helper"

class PushNotificationJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    @subscription = PushSubscription.create!(user: @user, endpoint: "https://push.example.com/abc",
                                             p256dh_key: "llave", auth_key: "secreto")
  end

  test "a global alert reaches every subscribed device" do
    alert = Alert.create!(title: "Cambio de última hora", body: "Nos vemos en el auditorio",
                          sender_name: "Coordinación", audience: :todos)
    sent = capture_sends { PushNotificationJob.new.perform(alert.id) }

    assert_equal 1, sent.size
    payload = JSON.parse(sent.first[:message])
    assert_equal "Cambio de última hora", payload["title"]
    assert_equal "Nos vemos en el auditorio", payload.dig("options", "body")
    assert_equal "/alertas/#{alert.id}", payload.dig("options", "data", "path")
  end

  test "a critical alert is marked as urgent and insists" do
    alert = Alert.create!(title: "Emergencia", body: "Todos al comedor", sender_name: "Dirección",
                          audience: :todos, priority: :critica)
    sent = capture_sends { PushNotificationJob.new.perform(alert.id) }
    payload = JSON.parse(sent.first[:message])

    assert_equal "high", sent.first[:urgency]
    assert payload.dig("options", "requireInteraction")
    assert_match(/🔴/, payload["title"])
  end

  test "an alert for one person does not reach anybody else" do
    other = Participant.create!(first_name: "Otra", last_name: "Persona", age: 30, stake: "las_americas",
                                shirt_number: "m", gender: "M", rol: :consejero)
    alert = Alert.create!(title: "Tu asignación", body: "Revisa tu perfil", sender_name: "Coordinación",
                          audience: :individual, recipient: other)

    assert_empty capture_sends { PushNotificationJob.new.perform(alert.id) }
  end

  test "a device the browser already forgot is dropped" do
    alert = Alert.create!(title: "Aviso", body: "Texto", sender_name: "Coordinación", audience: :todos)
    gone = WebPush::ExpiredSubscription.new(Struct.new(:body).new("gone"), "push.example.com")

    stubbing_push(->(**) { raise gone }) do
      assert_difference -> { PushSubscription.count }, -1 do
        PushNotificationJob.new.perform(alert.id)
      end
    end
  end

  test "creating an alert queues the delivery" do
    assert_enqueued_with(job: PushNotificationJob) do
      Alert.create!(title: "Nueva", body: "Texto", sender_name: "Coordinación", audience: :todos)
    end
  end

  private
    # WebPush habla con servidores externos: aquí solo se anota qué se habría enviado.
    def capture_sends(&block)
      sent = []
      stubbing_push(->(**options) { sent << options }, &block)
      sent
    end

    def stubbing_push(behaviour)
      original = WebPush.method(:payload_send)
      WebPush.define_singleton_method(:payload_send) { |**options| behaviour.call(**options) }
      yield
    ensure
      WebPush.singleton_class.send(:define_method, :payload_send, original)
    end
end
