require "test_helper"

class NightAttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @branch = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 3, auxiliar_company: @branch)
    @other = Company.create!(number: 4, auxiliar_company: @branch)
    @juan = participants(:juan).tap { |joven| joven.update!(company: @company) }
    @ana = person("Ana", "joven", "M", company: @company)

    @counselor = person("Carlos", "consejero", "H")
    @company.memberships.create!(participant: @counselor)
    @director = person("Dir", "director", "M")
    travel_to Time.zone.local(2027, 1, 11, 21)
  end

  test "the male counselor takes the men's list of his company, and only that one" do
    sign_in_as account(@counselor)

    get company_night_attendance_path(@company)
    assert_response :success
    assert_select "[data-night-joven='#{@juan.id}'] [data-night-toggle]"
    assert_select "[data-night-joven='#{@ana.id}']", 0

    patch company_night_attendance_path(@company, genero: "H"), params: { marks: { @juan.id => { status: "presente" } } }
    assert_redirected_to company_night_attendance_path(@company, genero: "H")
    list = NightAttendance.find_by!(company: @company, night_on: Date.new(2027, 1, 11), gender: "H")
    assert_equal "Carlos Prueba", list.taken_by_name
    assert_equal "Pasó la asistencia nocturna de Compañía 3 (hombres): 1 presente y 0 ausentes", AuditLog.asistencia.last.summary

    assert_no_difference -> { NightAttendance.count } do
      patch company_night_attendance_path(@company, genero: "M"), params: { marks: { @ana.id => { status: "presente" } } }
    end
    get company_night_attendance_path(@company, genero: "M")
    assert_select "[data-night-toggle]", 0 # la de las mujeres de su compañía la ve, pero no la pasa
  end

  test "a counselor can't open another company nor the panel" do
    sign_in_as account(@counselor)

    get company_night_attendance_path(@other)
    assert_redirected_to dashboard_path
    get night_attendances_path
    assert_redirected_to dashboard_path
  end

  test "the auxiliar of the same gender takes the list when the counselor is missing" do
    auxiliar = person("Laura", "auxiliar", "M")
    @branch.memberships.create!(participant: auxiliar)
    sign_in_as account(auxiliar)

    get company_night_attendance_path(@company)
    assert_select "[data-night-joven='#{@ana.id}'] [data-night-toggle]"

    patch company_night_attendance_path(@company, genero: "M"),
          params: { marks: { @ana.id => { status: "ausente", absence_reason: "enfermeria" } } }
    assert NightAttendance.find_by!(company: @company, gender: "M").mark_for(@ana).ausente?

    get night_attendances_path
    assert_response :success, "auxiliares see every company in the panel"
  end

  test "a list can't be confirmed with someone unmarked or an absence without its reason" do
    sign_in_as account(@counselor)

    patch company_night_attendance_path(@company, genero: "H"), params: { marks: { @juan.id => { status: "ausente", absence_reason: "otro" } } }
    assert_response :unprocessable_entity
    assert_select "[data-night-errors]", text: /escribe el motivo/
    assert_equal 0, NightAttendance.count
  end

  test "the panel shows who took their list and who is missing" do
    NightAttendance.new(company: @company, night_on: Date.new(2027, 1, 11), gender: "H")
                   .record({ @juan.id => { status: "ausente", absence_reason: "otro", absence_detail: "Con sus papás" } }, taken_by: @counselor)
    sign_in_as account(@director)

    get night_attendances_path
    assert_response :success
    assert_select "[data-night-list='3-H'][data-night-list-status=ausentes]", text: /1 falta/
    assert_select "[data-night-list='3-M'][data-night-list-status=pendiente]", text: /Sin pasar/
    assert_select "[data-night-missing]", 0, "who is missing is inside the list, not on the card"

    get company_night_attendance_path(@company, genero: "H")
    assert_select "[data-night-joven='#{@juan.id}']", text: /Ausente · Con sus papás/
    assert_select "[data-night-toggle]", 0, "directors follow the lists, they don't take them"
  end

  test "the superadmin can take any list, but only on the test night before the event" do
    travel_to Time.zone.local(2026, 10, 5, 20)
    sign_in_as users(:one)

    get night_attendances_path
    assert_select "[data-night-option='2026-10-05']", text: "Hoy · prueba"
    assert_select "[data-night-option='2027-01-11']"

    patch company_night_attendance_path(@company, genero: "M"), params: { marks: { @ana.id => { status: "presente" } } }
    assert_equal "Administrador del sistema", NightAttendance.find_by!(company: @company, gender: "M").taken_by_name

    travel_to Time.zone.local(2027, 1, 12, 21)
    sign_in_as users(:one) # la sesión de octubre ya venció
    get company_night_attendance_path(@company, genero: "H")
    assert_response :success
    assert_select "[data-night-toggle]", 0, "during the event only the counselors take it"
    get night_attendances_path
    assert_select "[data-night-option='2027-01-12']"
    assert_select "[data-night-option]", 5
  end

  test "opened from the panel, the company's profile and its list go back to the panel" do
    sign_in_as account(@director)
    panel = night_attendances_path(noche: "2027-01-11")

    get company_path(@company, return_to: panel)
    assert_select "a[title='Volver a Asistencia nocturna'][href='#{panel}']"
    assert_select "a", text: /Gafetes/, count: 0
    assert_select "a[href^='#{company_night_attendance_path(@company)}']", text: /Asistencia nocturna/

    get company_night_attendance_path(@company, genero: "H", return_to: panel)
    assert_select "a[title='Volver a Asistencia nocturna'][href='#{panel}']"
  end

  test "past nights are read-only" do
    sign_in_as account(@counselor)

    get company_night_attendance_path(@company, noche: "2027-01-10")
    assert_select "[data-night-toggle]", 0
  end

  private
    def person(name, rol, gender, company: nil)
      Participant.create!(first_name: name, last_name: "Prueba", age: 30, stake: "bello_horizonte", ward: "la_rotonda",
                          shirt_number: "m", gender: gender, rol: rol, company: company)
    end

    def account(participant)
      User.create!(email_address: "#{participant.first_name.downcase}@fsy.com", password: "Prueba123!", participant: participant)
    end
end
