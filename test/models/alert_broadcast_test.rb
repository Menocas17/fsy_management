require "test_helper"

# La campanita de quien tenga la app abierta se refresca sola por Action Cable.
class AlertBroadcastTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @admin = users(:one)
    @counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
  end

  test "a global alert refreshes every bell" do
    assert_enqueued_with(job: Turbo::Streams::ActionBroadcastJob) do
      Alert.create!(title: "Aviso", body: "Texto", sender_name: "Coordinación", audience: :todos)
    end
  end

  test "an alert by role only refreshes the bells of those roles" do
    alert = Alert.new(title: "Solo consejeros", body: "Texto", sender_name: "Coordinación",
                      audience: :por_roles, target_roles: [ "consejero" ])

    assert_equal [ @counselor ], alert.push_recipients.to_a
  end

  test "an individual alert reaches only that person" do
    alert = Alert.new(title: "Tu asignación", body: "Texto", sender_name: "Coordinación",
                      audience: :individual, recipient: participants(:maria))

    assert_equal [ @counselor ], alert.push_recipients.to_a
  end

  test "the bell carries its unread count, which is what makes it chime" do
    Alert.create!(title: "Primera", body: "Texto", sender_name: "Coordinación", audience: :todos)
    Alert.create!(title: "Segunda", body: "Texto", sender_name: "Coordinación", audience: :todos)

    html = ApplicationController.render(partial: "shared/notifications_bell", locals: { user: @counselor })

    assert_includes html, 'data-controller="alert-chime"'
    assert_includes html, 'data-alert-chime-unread-value="2"'
    assert_includes html, "/notificaciones/campanita"
  end

  test "the badge is always in the HTML, hidden when there is nothing to read" do
    html = ApplicationController.render(partial: "shared/notifications_bell", locals: { user: @admin })

    # Se dibuja siempre para que al volver de la caché baste con ocultarla, sin crear elementos.
    assert_includes html, "data-unread-count"
    assert_includes html, "hidden"
  end

  test "the bell renders outside a request, which is how the broadcast draws it" do
    Alert.create!(title: "Aviso nuevo", body: "Texto", sender_name: "Coordinación", audience: :todos)

    html = ApplicationController.render(partial: "shared/notifications_bell", locals: { user: @counselor })

    assert_includes html, "notifications_bell"
    assert_includes html, "Aviso nuevo"
    assert_includes html, "data-unread-count"
  end
end
