require "application_system_test_case"

class CompanyStaffingTest < ApplicationSystemTestCase
  setup do
    @company = Company.create!(number: 1)
    @pedro = Participant.create!(first_name: "Pedro", last_name: "Ruiz", age: 24, stake: "villa_flor",
                                 shirt_number: "m", gender: "H", rol: "consejero")
    @luis = Participant.create!(first_name: "Luis", last_name: "Mora", age: 23, stake: "villa_flor",
                                shirt_number: "m", gender: "H", rol: "consejero")
  end

  test "asignar un consejero llena su vacante y ya no ofrece otro hombre" do
    sign_in_as(users(:one))
    visit edit_company_path(@company)

    select "Pedro Ruiz · Hombre", from: "Agregar consejero"
    click_on "Asignar"

    assert_text "Personal asignado."
    within("[data-leader-slot='consejero-H']") { assert_text "Pedro Ruiz" }
    # 1 hombre y 1 mujer por rol: con el hombre puesto solo queda ofrecer a la consejera.
    assert_select "Agregar consejero", with_options: [ "María García · Mujer" ]
    assert_no_select "Agregar consejero", with_options: [ "Luis Mora · Hombre" ]
  end

  test "quitar un consejero pide confirmación y deja la vacante libre" do
    @company.memberships.create!(participant: @pedro)
    sign_in_as(users(:one))
    visit edit_company_path(@company)

    within("[data-leader-slot='consejero-H']") { click_on "Quitar" }
    click_on "Sí, quitar"

    assert_text "Personal removido."
    assert_selector "[data-leader-slot='consejero-H'][data-vacant]"
    assert_empty @company.reload.counselors
  end

  test "el consejero ve a sus líderes pero no cambia la plantilla de su compañía" do
    @company.memberships.create!(participant: participants(:maria))
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)),
               password: "Consejera1!")
    visit edit_company_path(@company)

    within("[data-leader-slot='consejero-M']") { assert_text "María García" }
    assert_text "los asigna tu coordinación"
    assert_no_field "Agregar consejero"
    assert_no_button "Quitar"
  end
end
