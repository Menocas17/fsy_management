require "application_system_test_case"

# Entrar a una ficha desde una lista filtrada y volver (con el «Volver» de la ficha o con el del navegador)
# deja la lista como estaba, también en el teléfono, donde las tarjetas volvían a la lista sin filtros.
class ParticipantFiltersReturnTest < ApplicationSystemTestCase
  setup { sign_in_as users(:one) }

  test "on the phone, a card's «Volver» and the browser's back keep the filters" do
    resize_to_mobile
    visit participants_path(stake: "bello_horizonte")
    find("a[href*='return_to']", text: "Juan Pérez").click
    assert_current_path(/return_to=.*stake%3Dbello_horizonte/)

    page.go_back
    assert_current_path(/stake=bello_horizonte/)
    assert_equal "bello_horizonte", find("#stake", visible: :all).value
  end

  test "on desktop the browser's back keeps a typed search" do
    visit participants_path
    fill_in "Buscar por nombre", with: "Juan"
    assert_current_path(/query=Juan/)
    find("[id$=_table] a[href*='return_to']", text: "Juan Pérez", match: :first).click
    assert_current_path(/return_to=.*query%3DJuan/)

    page.go_back
    assert_current_path(/query=Juan/)
    assert_field "Buscar por nombre", with: "Juan"
  end
end
