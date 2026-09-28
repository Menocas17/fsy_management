require "test_helper"

class ParticipantImportRowTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(number: 3)
    @import = ParticipantImport.create!(filename: "carga.xlsx", uploaded_by_name: "Admin")
  end

  def pending_row(values)
    row = @import.rows.create!(row_number: 2, values: values, status: :pending)
    row.reevaluate!
    row
  end

  test "a blocked row cannot be approved until it is corrected, and then it goes in with its staffing" do
    Participant.create!(first_name: "Luis", last_name: "Uno", age: 25, stake: "villa_flor", shirt_number: "m", gender: "H", rol: :consejero)
      .then { |luis| Membership.create!(associable: @company, participant: luis) }
    row = pending_row("first_name" => "Beto", "last_name" => "Tres", "age" => 26, "gender" => "H", "stake" => "villa_flor",
                      "shirt_number" => "l", "rol" => "consejero", "company_number" => "3")

    assert row.blocking?
    assert_no_difference -> { Participant.count } do
      refute row.approve!("Admin")
    end
    assert row.reload.pending?

    row.update!(values: row.values.merge("gender" => "M", "first_name" => "Bea"))
    row.reevaluate!
    refute row.blocking?
    assert row.approve!("Admin")
    assert row.reload.approved?
    assert_equal "Admin", row.resolved_by_name
    assert_equal [ "Luis", "Bea" ], @company.memberships.includes(:participant).map { |m| m.participant.first_name }
  end

  test "a warning can be approved knowingly; discarding keeps it out of the base" do
    row = pending_row("first_name" => "Sara", "last_name" => "Cuatro", "age" => 23, "gender" => "M", "stake" => "villa_flor",
                      "shirt_number" => "s", "rol" => "consejero")
    refute row.blocking?
    assert row.approve!("Admin")
    assert Participant.exists?(first_name: "Sara")

    other = pending_row("first_name" => "Otra", "last_name" => "Persona", "age" => 30)
    assert_no_difference -> { Participant.count } do
      other.discard!("Admin")
    end
    assert other.reload.discarded?
  end
end
