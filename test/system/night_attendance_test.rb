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

  test "the counselor taps each joven present, and Falta asks for the reason" do
    sign_in_as(@user, password: "Prueba123!")
    visit company_path(@company)
    click_on "Pasar asistencia"

    assert_button "Confirmar asistencia", disabled: true
    find("[data-night-joven='#{@juan.id}'] [data-night-toggle]").click
    find("[data-night-joven='#{@luis.id}'] [data-night-toggle]").click
    within("[data-night-joven='#{@juan.id}']") { assert_text "Presente" }
    assert_text "2 de 3"

    find("[data-night-joven='#{@pedro.id}'] [data-night-falta]").click
    within("dialog[open]") do
      assert_button "Marcar ausente", disabled: true
      click_on "Otro motivo"
      find("input[placeholder='¿Dónde está?']").fill_in(with: "Con sus papás")
      save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-hoja.png")) if ENV["SCREENSHOTS"]
      click_on "Marcar ausente"
    end
    within("[data-night-joven='#{@pedro.id}']") { assert_text "Ausente · Con sus papás" }
    assert_selector "li[data-night-joven]:first-child[data-night-joven='#{@pedro.id}']" # el ausente sube al principio
    assert_text "3 de 3"
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
    save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-panel.png")) if ENV["SCREENSHOTS"]
  end

  test "on a phone the list fits without scrolling sideways and the reason opens as a sheet" do
    resize_to_mobile
    sign_in_as(@user, password: "Prueba123!")
    visit company_night_attendance_path(@company)
    find("[data-night-joven='#{@juan.id}'] [data-night-toggle]").click
    save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-celular.png")) if ENV["SCREENSHOTS"]
    find("[data-night-joven='#{@pedro.id}'] [data-night-falta]").click
    within("dialog[open]") { click_on "Enfermería" }
    save_screenshot(File.join(ENV["SCREENSHOTS"], "asistencia-celular-hoja.png")) if ENV["SCREENSHOTS"]

    assert_equal page.evaluate_script("document.documentElement.clientWidth"), page.evaluate_script("document.documentElement.scrollWidth")
  end

  private
    def person(name, rol, company: nil)
      Participant.create!(first_name: name, last_name: "Prueba", age: 17, stake: "bello_horizonte", ward: "ducuali",
                          shirt_number: "m", gender: "H", rol: rol, company: company)
    end
end
