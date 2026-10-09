require "test_helper"

class DateInputTest < ActionView::TestCase
  include UiHelper
  include RailsIcons::Helpers::IconHelper

  test "shows the date as day/month/year whatever the phone's language" do
    render inline: date_input("participant[birth_date]", Date.new(2010, 3, 14), id: "participant_birth_date", max: Date.new(2026, 10, 8))

    assert_select "input[type=text][name='participant[birth_date]'][id=participant_birth_date][value='14/03/2010'][placeholder='dd/mm/aaaa']"
    assert_select "input[type=date]:not([name])[value='2010-03-14'][max='2026-10-08']"
    assert_select "[data-controller=date-input][data-date-input-max-value='2026-10-08']"
  end

  test "an ISO string (the agenda's date) and an empty value both work" do
    render inline: date_input("activity[date]", "2027-01-11")
    assert_select "input[type=text][value='11/01/2027']"

    render inline: date_input("expense[planned_on]", nil)
    assert_select "input[type=text][name='expense[planned_on]']:not([value])"
  end

  test "what it sends is read by Rails as day/month/year" do
    assert_equal Date.new(2010, 3, 14), Participant.new(birth_date: "14/03/2010").birth_date
    assert_nil Participant.new(birth_date: "03/14/2010").birth_date
  end
end
