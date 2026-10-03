require "test_helper"

class AuditLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    AuditLog.create!(actor_name: "Marta Jiménez", action: "updated", category: :companias,
                     summary: "Actualizó nombre de la compañía Alfa 1", target_name: "Alfa 1")
    AuditLog.create!(actor_name: "Rodolfo Menocal", action: "updated", category: :asignaciones,
                     summary: "Actualizó cuarto de Camila Martínez", target_name: "Camila Martínez")
  end

  test "lists activity for staff managers" do
    get audit_logs_path

    assert_response :success
    assert_includes response.body, "Actualizó nombre de la compañía Alfa 1"
    assert_includes response.body, "Actualizó cuarto de Camila Martínez"
  end

  test "filters by category" do
    get audit_logs_path(category: "companias")

    assert_includes response.body, "Alfa 1"
    refute_includes response.body, "Camila Martínez"
  end

  test "searches by name" do
    get audit_logs_path(query: "Rodolfo")

    assert_includes response.body, "Camila Martínez"
    refute_includes response.body, "Alfa 1"
  end

  test "is hidden from staff without management access" do
    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get audit_logs_path

    assert_redirected_to dashboard_path
  end

  test "searches what was done too, without caring about accents" do
    AuditLog.create!(actor_name: "Ana Pérez", action: "voided", category: :registro,
                     summary: "Anuló la llegada de Juan Pérez (Gafete equivocado)", target_name: "Juan Pérez")

    get audit_logs_path(query: "anulo")

    assert_select "[data-audit-log-id]", 1
    assert_includes response.body, "Anuló la llegada de Juan Pérez"
  end

  test "filters by kind of action and by date" do
    AuditLog.create!(actor_name: "Ana Pérez", action: "voided", category: :registro,
                     summary: "Anuló la llegada de Juan Pérez (Gafete equivocado)", target_name: "Juan Pérez",
                     created_at: 3.days.ago)

    get audit_logs_path(kind: "anulo")
    assert_select "[data-audit-log-id]", 1
    assert_select "[data-audit-log-id] [data-audit-kind='Anuló']"

    get audit_logs_path(kind: "anulo", period: "hoy")
    assert_select "[data-audit-log-id]", 0
    assert_select "[data-empty-state='audit-logs']", text: /Nada coincide/
    assert_select "a[data-audit-clear]", "Quitar filtros"
  end

  test "names what was affected with a link while it still exists" do
    juan = participants(:juan)
    AuditLog.create!(actor_name: "Ana Pérez", action: "updated", category: :participantes, summary: "Actualizó cuarto de Juan Pérez",
                     target_type: "Participant", target_id: juan.id, target_name: "Juan Pérez")
    AuditLog.create!(actor_name: "Ana Pérez", action: "destroyed", category: :participantes, summary: "Eliminó el registro de Fulano",
                     target_type: "Participant", target_id: SecureRandom.uuid, target_name: "Fulano")

    get audit_logs_path

    assert_select "table a[href='#{participant_path(juan)}']", "Juan Pérez"
    assert_select "table a", { text: "Fulano", count: 0 }, "lo borrado queda como texto"
  end
end
