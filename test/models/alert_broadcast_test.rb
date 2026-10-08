require "test_helper"

# La campanita de quien tenga la app abierta se refresca sola por Action Cable: un solo aviso para todos
# (stream "alerts"), y cada campanita pregunta su número.
class AlertBroadcastTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @admin = users(:one)
    @counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
  end

  test "an alert sends one signal for every open bell, not one bell per account" do
    User.create!(email_address: "otra@fsy.com", password: "Consejera1!", participant: participants(:juan))

    assert_enqueued_jobs 1, only: Turbo::Streams::ActionBroadcastJob do
      Alert.create!(title: "Aviso", body: "Texto", sender_name: "Coordinación", audience: :todos)
    end
  end

  test "the signal carries nothing of the alert, since it reaches everyone with the app open" do
    alert = Alert.create!(title: "Solo consejeros", body: "Secreto", sender_name: "Coordinación",
                          audience: :por_roles, target_roles: [ "consejero" ])

    html = ApplicationController.render(partial: "shared/alerts_signal", locals: { alert: alert })

    assert_includes html, 'id="alerts_signal"'
    assert_includes html, 'data-controller="alert-signal"'
    assert_not_includes html, "Solo consejeros"
    assert_not_includes html, "Secreto"
  end

  test "an alert by role only refreshes the bells of those roles, plus the superadmin's, which shows them all" do
    alert = Alert.new(title: "Solo consejeros", body: "Texto", sender_name: "Coordinación",
                      audience: :por_roles, target_roles: [ "consejero" ])

    assert_equal [ @admin, @counselor ].sort_by(&:id), alert.push_recipients.sort_by(&:id)
  end

  test "an individual alert rings only that person" do
    alert = Alert.new(title: "Tu asignación", body: "Texto", sender_name: "Coordinación",
                      audience: :individual, recipient: participants(:maria))

    assert_equal [ @counselor ], alert.push_recipients.to_a
  end

  test "an agenda alert for some roles still rings the superadmin, where it counts as unread" do
    activity = Activity.create!(title: "Taller", category: :clase, date: Activity.event_days.first.to_s,
                                start_time: "10:00", end_time: "11:00", audience: :por_roles, target_roles: [ "joven" ])

    alert = Alert.announce(activity, action: :created, user: nil)

    assert_includes alert.push_recipients, @admin
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

  test "the bell's list isn't drawn with every page: its menu asks for it when it opens" do
    Alert.create!(title: "Aviso nuevo", body: "Texto", sender_name: "Coordinación", audience: :todos)

    html = ApplicationController.render(partial: "shared/notifications_bell", locals: { user: @counselor })

    assert_includes html, "data-unread-count"
    assert_includes html, 'src="/notificaciones/menu"'
    assert_includes html, 'loading="lazy"'
    assert_not_includes html, "Aviso nuevo"
  end
end
