require "test_helper"

class AgendaControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @first_day = Rails.configuration.x.event_start_on
    @last_day = Rails.configuration.x.event_end_on
    @day = @first_day + 1
    @activity = Activity.create!(title: "Servicio comunitario", category: :servicio, location: "La Rotonda",
                                 date: @day.to_s, start_time: "10:00", end_time: "12:30",
                                 logistics_notes: "30 galones de pintura", youth_notes: "Llevar gorra")
  end

  test "the colour legend sits above the agenda, not under it" do
    get agenda_path(date: @day)

    assert_select "[data-agenda-legend]", 1
    assert_operator response.body.index("data-agenda-legend"), :<, response.body.index("data-activity-id"),
                    "la leyenda se lee antes de recorrer la agenda"
  end

  test "shows the days of the event with the detail of the selected activity" do
    get agenda_path(date: @day)

    assert_response :success
    assert_select "a[data-activity-id='#{@activity.id}']"
    assert_select "[data-activity-title]", "Servicio comunitario"
    assert_select "[data-role-note='logistica']", text: /30 galones/
    assert_includes response.body, "11 – 16 de enero, 2027"
  end

  test "there is nowhere to navigate outside the event: other dates land inside it" do
    get agenda_path(date: "2026-12-01", view: "dia")

    assert_response :success
    assert_includes response.body, "Lunes 11 de enero"
    assert_select "a[aria-label='Día anterior']", 0, "the first day has no previous day"

    get agenda_path(date: "2027-05-20", view: "dia")
    assert_includes response.body, "Sábado 16 de enero"
    assert_select "a[aria-label='Día siguiente']", 0
  end

  test "the arrows move one day at a time in the day view" do
    get agenda_path(date: @day, view: "dia")

    assert_select "a[href='#{agenda_path(date: @day - 1, view: "dia")}'][aria-label='Día anterior']"
    assert_select "a[href='#{agenda_path(date: @day + 1, view: "dia")}'][aria-label='Día siguiente']"
  end

  test "the day view shows one day and the week view shows them all" do
    Activity.create!(title: "Devocional", category: :devocional, date: (@day + 1).to_s, start_time: "08:30", end_time: "09:50")

    get agenda_path(date: @day, view: "dia")
    assert_select "a[data-activity-id]", 1
    assert_select "details[data-activity-id]", 1

    get agenda_path(date: @day, view: "semana")
    assert_select "a[data-activity-id]", 2
    assert_select "details[data-activity-id]", 2
  end

  test "on phones each activity opens in place, with its notes inside" do
    get agenda_path(date: @day, view: "dia")

    assert_select "details[data-activity-id='#{@activity.id}'] [data-role-note='logistica']", text: /30 galones/
  end

  test "a joven reads only their own note and gets no edit buttons" do
    sign_out
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)))

    get agenda_path(date: @day)

    assert_response :success
    assert_select "[data-role-note='jovenes']", text: /Llevar gorra/
    assert_select "[data-role-note='logistica']", 0
    assert_select "a[href='#{new_activity_path}']", 0
    assert_select "a[href='#{edit_activity_path(@activity)}']", 0
  end

  test "an empty day explains itself" do
    get agenda_path(date: @last_day, view: "dia")

    assert_response :success
    assert_includes response.body, "Sin actividades este día"
  end
end
