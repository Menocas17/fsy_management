require "application_system_test_case"

class AgendaOnPhoneTest < ApplicationSystemTestCase
  test "opening an activity on the phone brings its detail and the notes for your role" do
    day = Rails.configuration.x.event_start_on + 1
    activity = Activity.create!(title: "Servicio comunitario", category: :actividad, location: "La Rotonda",
                                date: day.to_s, start_time: "10:00", end_time: "12:30", youth_notes: "Llevar gorra")
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)),
               password: "Joven1234!")
    resize_to_mobile

    visit agenda_path(date: day, view: "dia")
    within("details[data-activity-id='#{activity.id}']") do
      assert_no_selector "[data-role-note]", visible: :all
      find("summary").click

      assert_selector "[data-role-note='jovenes']", text: "Llevar gorra"
      assert_text "La Rotonda"
    end
  end
end
