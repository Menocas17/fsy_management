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

  test "an alert by role only refreshes the bells of those roles, plus the superadmin's, which shows them all" do
    alert = Alert.new(title: "Solo consejeros", body: "Texto", sender_name: "Coordinación",
                      audience: :por_roles, target_roles: [ "consejero" ])

    assert_equal [ @admin, @counselor ].sort_by(&:id), alert.push_recipients.sort_by(&:id)
  end

  test "an individual alert rings only that person, though the superadmin's open bell refreshes too" do
    alert = Alert.new(title: "Tu asignación", body: "Texto", sender_name: "Coordinación",
                      audience: :individual, recipient: participants(:maria))

    assert_equal [ @counselor ], alert.push_recipients.to_a
    assert_equal [ @admin, @counselor ].sort_by(&:id), alert.bell_recipients.sort_by(&:id)
  end

  test "an agenda alert for some roles still refreshes the superadmin's bell, where it counts as unread" do
    activity = Activity.create!(title: "Taller", category: :clase, date: Activity.event_days.first.to_s,
                                start_time: "10:00", end_time: "11:00", audience: :por_roles, target_roles: [ "joven" ])

    alert = Alert.announce(activity, action: :created, user: nil)

    assert_includes alert.push_recipients, @admin
    assert_includes alert.bell_recipients, @admin
    assert_equal 1, @admin.unread_alerts_count
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
