require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "creating a company records who did it" do
    assert_difference -> { AuditLog.companias.count }, 1 do
      post companies_path, params: { company: { name: "Alfa 9" } }
    end

    log = AuditLog.recent.first
    assert_equal "Administrador del sistema", log.actor_name
    assert_equal "Creó la compañía Alfa 9", log.summary
    assert_equal "Alfa 9", log.target_name
  end

  test "updating a company summarizes the changed fields and skips no-op saves" do
    company = Company.create!(name: "Alfa 1")

    patch company_path(company), params: { company: { name: "Alfa Uno" } }
    assert_equal "Actualizó nombre de la compañía Alfa Uno", AuditLog.recent.first.summary

    assert_no_difference -> { AuditLog.count } do
      patch company_path(company), params: { company: { name: "Alfa Uno" } }
    end
  end

  test "assigning and removing staff are both recorded" do
    company = Company.create!(name: "Alfa 3")

    post assign_staff_company_path(company), params: { participant_id: participants(:maria).id }
    assert_equal "Asignó a María García como consejero en Alfa 3", AuditLog.recent.first.summary

    membership = company.memberships.first
    delete remove_staff_company_path(company, membership_id: membership.id)
    assert_equal "Removió a María García de Alfa 3", AuditLog.recent.first.summary
  end
end
