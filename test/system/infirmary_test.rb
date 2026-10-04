require "application_system_test_case"

class InfirmaryTest < ApplicationSystemTestCase
  setup do
    company = Company.create!(number: 7)
    @joven = Participant.create!(first_name: "Valeria", last_name: "Mendoza", age: 16, stake: "bello_horizonte", ward: "ducuali",
                                 shirt_number: "m", gender: "M", rol: "joven", company: company, allergies: "Penicilina")
    @visit = InfirmaryVisit.admit_directly(@joven, by: nil, reason: "fiebre", detail: "38.4 y dolor de garganta").tap(&:start)
    sign_in_as(users(:one))
  end

  test "the whole card opens the chart, and its buttons still do their own thing" do
    visit infirmary_visits_path
    card = find("[data-infirmary-visit='#{@joven.id}']")

    card.find("[data-infirmary-action=alta]").click
    assert_selector "dialog[open]", text: "Dar de alta a Valeria Mendoza"
    assert_current_path infirmary_visits_path
    within("dialog[open]") { click_on "Cancelar" }

    # Un toque sobre el cuerpo de la tarjeta (el motivo), lejos del nombre: el enlace estirado lo recibe.
    detail = card.find("[data-infirmary-detail]")
    box, spot = card.rect, detail.rect
    card.click(x: spot.x + 20 - (box.x + box.width / 2), y: spot.y + 8 - (box.y + box.height / 2)) # desde el centro (w3c)
    assert_current_path infirmary_chart_path(@joven)
  end

  test "a note is text plus the vital signs, if they were taken" do
    visit infirmary_chart_path(@joven)
    fill_in "Nota", with: "Acetaminofén 500 mg"
    find("summary", text: "Signos vitales").click
    fill_in "Temperatura (°C)", with: "38.6"
    click_on "Agregar a la ficha"

    assert_selector "[data-infirmary-note]", text: "Acetaminofén 500 mg"
    assert_selector "[data-vital='38.6 °C']"
  end
end
