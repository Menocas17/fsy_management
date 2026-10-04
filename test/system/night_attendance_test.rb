require "application_system_test_case"

# El consejero pasa la lista de su compañía a mano. SCREENSHOTS=dir guarda capturas.
class NightAttendanceTest < ApplicationSystemTestCase
  setup do
    travel_to Time.zone.local(2027, 1, 11, 21)
    @company = Company.create!(number: 3, auxiliar_company: AuxiliarCompany.create!(name: "Auxiliar Alfa"))
    @juan = participants(:juan).tap { |joven| joven.update!(company: @company, room: "301") }
    @pedro = person("Pedro", "joven", company: @company)
    @luis = person("Luis", "joven", company: @company)
    counselor = person("Carlos", "consejero")
    @company.memberships.create!(participant: counselor)
    @user = User.create!(email_address: "carlos@fsy.com", password: "Prueba123!", participant: counselor)
  end

  test "the counselor marks his jóvenes, with a reason for whoever is missing" do
    sign_in_as(@user, password: "Prueba123!")
    visit company_path(@company)
    click_on "Pasar asistencia"

    within("[data-night-joven='#{@pedro.id}']") do
      assert_no_selector "[data-night-reason-box]", visible: true
      find("label", text: "Ausente").click
      assert_selector "[data-night-reason-box]", visible: true
      assert_no_selector "[data-night-detail]", visible: true
      find("label", text: "Otro").click
      find("[data-night-detail]").fill_in(with: "Con sus papás")
    end
    click_on "Todos presentes"
    within("[data-night-joven='#{@pedro.id}']") { assert find("[data-night-status=ausente]", visible: :all).checked? }
    save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-escritorio.png")) if ENV["SCREENSHOTS"]

    click_on "Confirmar asistencia"
    assert_selector "[data-night-status]", text: "Confirmada por Carlos Prueba"
    list = NightAttendance.last
    assert_equal %w[presente presente], [ list.mark_for(@juan).status, list.mark_for(@luis).status ]
    assert_equal "Con sus papás", list.mark_for(@pedro).reason_label

    sign_out
    director = person("Dir", "director")
    sign_in_as(User.create!(email_address: "dir@fsy.com", password: "Prueba123!", participant: director), password: "Prueba123!")
    visit night_attendances_path
    assert_selector "[data-night-list='3-H']", text: "1 falta"
    assert_selector "[data-night-absences]", text: "Pedro Prueba"
    save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-panel.png")) if ENV["SCREENSHOTS"]
  end

  test "on a phone the list fits without scrolling sideways" do
    resize_to_mobile
    sign_in_as(@user, password: "Prueba123!")
    visit company_night_attendance_path(@company)
    within("[data-night-joven='#{@pedro.id}']") do
      find("label", text: "Ausente").click
      find("label", text: "Otro").click
    end
    save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-celular.png")) if ENV["SCREENSHOTS"]

    assert_equal page.evaluate_script("document.documentElement.clientWidth"), page.evaluate_script("document.documentElement.scrollWidth")
  end

  private
    def person(name, rol, company: nil)
      Participant.create!(first_name: name, last_name: "Prueba", age: 17, stake: "bello_horizonte", ward: "ducuali",
                          shirt_number: "m", gender: "H", rol: rol, company: company)
    end
end
