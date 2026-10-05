require "test_helper"

class EventResetTest < ActiveSupport::TestCase
  test "deletes every ficha and what was done with them, and keeps the superadmin and the configuration" do
    admin = User.create!(email_address: "admin@example.com", password: "Una-clave-larga-123", superadmin: true, participant: participants(:juan))
    area = LogisticsArea.create!(name: "Finanzas", finance: true)
    staff = Participant.create!(first_name: "Lía", last_name: "Rocha", age: 30, shirt_number: "m", gender: "M", rol: "logistica",
                                stake: "villa_flor", logistics_area: area)
    User.create!(email_address: "lia@example.com", password: "Una-clave-larga-123", participant: staff)
    company = Company.create!(number: 1, auxiliar_company: AuxiliarCompany.create!(name: "Auxiliar Alfa"))
    participants(:maria).update!(company: company)
    Checkin.register(participant: participants(:maria), recorded_by: staff)
    Expense.create!(concept: "Hielo", estimated_cents: 5_000, presented_by: staff, presented_by_name: staff.full_name, logistics_area: area)
    Inventory.create!(name: "Materiales").items.create!(name: "Manillas").adjust!(delta: 5, participant: staff, reason: "compra")
    training = Training.create!(name: "Primera", held_on: Date.current)

    EventReset.new(out: StringIO.new).run

    assert_equal 0, Participant.count
    assert_equal [ admin, users(:one) ].map(&:id).sort, User.ids.sort, "only the superadmins stay"
    assert_nil admin.reload.participant_id, "the superadmin stays, without a ficha"
    assert_equal [ 0, 0, 0, 0, 0 ], [ Company.count, AuxiliarCompany.count, Checkin.count, Expense.count, InventoryItem.count ]
    assert LogisticsArea.exists?(area.id)
    assert Training.exists?(training.id)
    assert_equal 1, AuditLog.count
  end
end
