require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "company numbers are positive and unique" do
    Company.create!(name: "Compañía 1", number: 1)

    assert_not Company.new(name: "Otra", number: 1).valid?
    assert_not Company.new(name: "Cero", number: 0).valid?
    assert Company.new(name: "Sin número").valid?
  end

  test "sorts by number, not alphabetically" do
    [ 10, 2, 1 ].each { |number| Company.create!(name: "Compañía #{number}", number: number) }

    assert_equal [ 1, 2, 10 ], Company.by_number.pluck(:number)
  end

  test "the name always follows the number" do
    assert_equal "Compañía 7", Company.create!(number: 7).name
  end

  test "rejects an unknown dining hall instead of raising" do
    assert_not Company.new(number: 8, dining_hall: "cocina").valid?
  end

  test "jóvenes join through their company_id and staffing depends on counselors" do
    company = Company.create!(number: 5)
    participants(:juan).update!(company: company, room: "501")

    assert_equal [ participants(:juan) ], company.participants.to_a
    assert_equal({ "501" => 1 }, company.room_occupancy)
    assert_equal :no_counselors, company.staff_status

    company.memberships.create!(participant: participants(:maria))
    assert_equal :missing_counselor, company.reload.staff_status
    assert_equal "María García", company.counselor_names
  end

  test "search finds a company by number, chosen name or counselor" do
    first = Company.create!(number: 1, nickname: "Luz del Mundo")
    Company.create!(number: 12, nickname: "Roca Firme")
    first.memberships.create!(participant: participants(:maria))

    assert_equal [ first ], Company.search("1").to_a
    assert_equal [ first ], Company.search("luz").to_a
    assert_equal [ first ], Company.search("garcía").to_a
    assert_equal 2, Company.search("").count
  end

  test "counts jóvenes per dining hall with readable labels" do
    participants(:juan).update!(company: Company.create!(number: 6, dining_hall: :salon_nicaragua))

    assert_equal({ "Salón Nicaragua" => 1 }, Company.jovenes_by_dining_hall)
  end

  test "labels the dining hall" do
    assert_equal "Salón Las Américas", Company.new(dining_hall: :salon_las_americas).dining_hall_label
    assert_nil Company.new.dining_hall_label
  end
end
