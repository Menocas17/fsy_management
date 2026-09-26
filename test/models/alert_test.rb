require "test_helper"

class AlertTest < ActiveSupport::TestCase
  test "global alerts reach everyone and role alerts only their roles" do
    global = create_alert(audience: :todos)
    for_counselors = create_alert(audience: :por_roles, target_roles: %w[consejero])

    assert_equal [ global, for_counselors ].map(&:id).sort, Alert.visible_to(participants(:maria)).pluck(:id).sort
    assert_equal [ global.id ], Alert.visible_to(participants(:juan)).pluck(:id)
    assert_equal 2, Alert.visible_to(nil).count, "a superadmin sees every alert"
  end

  test "an individual alert only reaches the person it names" do
    personal = create_alert(audience: :individual, recipient: participants(:juan))

    assert_equal [ personal.id ], Alert.visible_to(participants(:juan)).pluck(:id)
    assert_empty Alert.visible_to(participants(:maria))
    assert_equal "Juan Pérez", personal.audience_label
  end

  test "an individual alert needs a recipient" do
    assert_not build_alert(audience: :individual).valid?
    assert build_alert(audience: :individual, recipient: participants(:juan)).valid?
  end

  test "role alerts need at least one role" do
    assert_not build_alert(audience: :por_roles, target_roles: []).valid?
    assert build_alert(audience: :por_roles, target_roles: %w[logistica]).valid?
  end

  test "only critical alerts can be emailed" do
    assert_not build_alert(priority: :importante, send_email: true).valid?
    assert build_alert(priority: :critica, send_email: true).valid?
  end

  test "email recipients are limited to accounts of the targeted roles" do
    users(:one).update!(participant: participants(:maria))
    critical = create_alert(priority: :critica, send_email: true, audience: :por_roles, target_roles: %w[consejero])

    assert_equal [ users(:one).id ], critical.email_recipients.pluck(:id)
    assert_empty create_alert(priority: :critica, audience: :todos).email_recipients, "without send_email nobody is emailed"
  end

  test "describes its audience in Spanish" do
    assert_equal "Todos los participantes", build_alert(audience: :todos).audience_label
    assert_equal "Logística y Consejero", build_alert(audience: :por_roles, target_roles: %w[logistica consejero]).audience_label
  end

  private
    def build_alert(**attributes)
      Alert.new({ title: "Aviso", body: "Contenido", sender_name: "Marta" }.merge(attributes))
    end

    def create_alert(**attributes)
      build_alert(**attributes).tap(&:save!)
    end
end
