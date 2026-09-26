require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  setup do
    @company_log = AuditLog.create!(actor_name: "Marta Jiménez", action: "updated", category: :companias,
                                    summary: "Actualizó nombre de la compañía Alfa 1", target_name: "Alfa 1", created_at: 2.hours.ago)
    @assignment_log = AuditLog.create!(actor_name: "Rodolfo Menocal", action: "updated", category: :asignaciones,
                                       summary: "Actualizó cuarto de Camila Martínez", target_name: "Camila Martínez", created_at: 1.hour.ago)
  end

  test "by_category filters by a known category" do
    assert_equal [ @company_log ], AuditLog.by_category("companias").to_a
  end

  test "by_category ignores blank or unknown categories" do
    assert_equal 2, AuditLog.by_category("").count
    assert_equal 2, AuditLog.by_category("inventada").count
  end

  test "search matches the actor or the affected target, case-insensitively" do
    assert_equal [ @company_log ], AuditLog.search("marta").to_a
    assert_equal [ @assignment_log ], AuditLog.search("camila").to_a
  end

  test "search treats LIKE wildcards as literal text" do
    assert_empty AuditLog.search("%").to_a
  end

  test "recent lists the newest entries first" do
    assert_equal [ @assignment_log, @company_log ], AuditLog.recent.to_a
  end
end
