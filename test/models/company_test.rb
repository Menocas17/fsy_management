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

  test "labels the dining hall" do
    assert_equal "Salón Las Américas", Company.new(dining_hall: :salon_las_americas).dining_hall_label
    assert_nil Company.new.dining_hall_label
  end
end
