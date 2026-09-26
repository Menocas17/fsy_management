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
end
