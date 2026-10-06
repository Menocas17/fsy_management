require "test_helper"

class EventSnapshotTest < ActiveSupport::TestCase
  test "loads db/seed_data/evento.json exactly as it was taken, matching areas, categories and trainings by name" do
    data = EventSnapshot.data
    admin = User.create!(email_address: "admin@example.com", password: "Una-clave-larga-123", superadmin: true)
    nursing = LogisticsArea.create!(name: "Enfermería", nursing: true)

    EventSnapshot.new(out: StringIO.new).run

    EventSnapshot::TABLES.each do |model|
      assert_equal data[model.table_name].size, model.count, model.table_name
    end
    sample = data["participants"].find { |row| row["rol"] == "joven" && row["company_id"] }
    joven = Participant.find(sample["id"])
    assert_equal [ sample["code"], sample["room"], sample["company_id"], sample["medical_info"] ],
                 [ joven.code, joven.room, joven.company_id, joven.medical_info ]

    assert_equal 1, LogisticsArea.where(name: [ "Enfermería", "Enfermeria" ]).count, "found by name without accents, not duplicated"
    nurse_ids = data["participants"].select { |row| row["logistics_area_id"] == data["logistics_areas"].find { _1["nursing"] }&.dig("id") }.pluck("id")
    assert_equal nurse_ids.sort, nursing.members.ids.sort
    assert_equal data["logistics_areas"].size, LogisticsArea.count
    assert admin.reload.superadmin?
    assert_equal data["expenses"].count { _1["expense_category_id"] }, Expense.where(expense_category_id: ExpenseCategory.select(:id)).count
  end

  test "dumping and loading again changes nothing" do
    path = Rails.root.join("tmp/evento_test.json")
    EventSnapshot.new(out: StringIO.new).run
    first = EventSnapshot.dump(path) && File.read(path)

    EventSnapshot.new(path, out: StringIO.new).run
    EventSnapshot.dump(path)
    assert_equal JSON.parse(first).except("logistics_areas", "expense_categories", "trainings"),
                 JSON.parse(File.read(path)).except("logistics_areas", "expense_categories", "trainings")
  ensure
    FileUtils.rm_f(path)
  end
end
