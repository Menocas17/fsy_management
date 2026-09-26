require "test_helper"

class AlertsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "sending an alert records it in the audit log and shows it in the bell" do
    assert_difference -> { Alert.count }, 1 do
      post alerts_path, params: { alert: { title: "Cambio de hora", body: "El devocional inicia a las 9:00.",
                                           audience: "todos", priority: "informativa" } }
    end

    alert = Alert.recent.first
    assert_redirected_to alerts_path
    assert_equal "Administrador del sistema", alert.sender_name
    assert_equal "Envió la alerta «Cambio de hora» a todos los participantes", AuditLog.alertas.recent.first.summary
    assert_equal 1, AuditLog.alertas.count, "the alert records itself once, not twice"

    get dashboard_path
    assert_select "[data-alert-id='#{alert.id}']", text: /Cambio de hora/
  end

  test "a role alert only reaches the chosen roles" do
    post alerts_path, params: { alert: { title: "Reunión de logística", body: "A las 6:00 en bodega.",
                                         audience: "por_roles", target_roles: [ "logistica" ], priority: "importante" } }

    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get notifications_path
    assert_response :success
    assert_select "[data-alert-id]", 0
    assert_select "[data-empty-state='notifications']"
  end

  test "critical alerts can also be emailed, other priorities can't" do
    # A second account so there is somebody to email; users(:one) stays the superadmin sending the alert.
    User.create!(email_address: "consejera@fsy.com", password: "Consejera1!", participant: participants(:maria))

    assert_no_difference -> { Alert.count } do
      post alerts_path, params: { alert: { title: "Aviso", body: "Texto", audience: "todos", priority: "importante", send_email: "1" } }
    end
    assert_response :unprocessable_entity

    assert_enqueued_emails 1 do
      post alerts_path, params: { alert: { title: "Evacuación", body: "Diríjanse al punto de encuentro.",
                                           audience: "todos", priority: "critica", send_email: "1" } }
    end
    assert Alert.recent.first.priority_critica?
  end

  test "the notifications page marks alerts as read and the bell stops counting them" do
    post alerts_path, params: { alert: { title: "Aviso", body: "Texto", audience: "todos", priority: "informativa" } }
    assert_equal 1, users(:one).reload.unread_alerts_count

    get notifications_path
    assert_select "[data-unread-count]", 0
    assert_equal 0, users(:one).reload.unread_alerts_count
  end

  test "only alert managers can open or send alerts" do
    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get new_alert_path
    assert_redirected_to notifications_path

    assert_no_difference -> { Alert.count } do
      post alerts_path, params: { alert: { title: "No", body: "No", audience: "todos", priority: "informativa" } }
    end
  end
end
