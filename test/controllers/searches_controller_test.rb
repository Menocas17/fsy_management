require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "asks for a couple of letters before searching" do
    get search_path(q: "m")

    assert_response :success
    assert_select "[data-search-results]", text: /Escribe al menos 2 letras/
    assert_select "[data-search-group]", false
  end

  test "finds people without caring about accents, with a filter per group" do
    get search_path(q: "garcia")

    assert_select "[data-search-group='personas'] a[href='#{participant_path(participants(:maria))}']", text: /María García/
    assert_select "[data-search-filters] a[href='#{search_path(q: "garcia", tipo: "personas")}']", text: "Personas · 1"
  end

  test "finds companies by number, places by name and menu modules" do
    company = Company.create!(number: 12)
    get search_path(q: "12")
    assert_select "[data-search-group='companias'] a[href='#{company_path(company)}']"

    get search_path(q: "villa")
    assert_select "[data-search-group='estacas'] a[href='#{participants_path(stake: "villa_flor")}']", text: /Estaca Villa Flor/
    assert_select "[data-search-group='estacas'] a[href='#{participants_path(ward: "villa_venezuela")}']", text: /Barrio Villa Venezuela/

    get search_path(q: "enfermeria")
    assert_select "[data-search-group='modulos'] a[href='#{infirmary_visits_path}']", text: /Enfermería/
  end

  test "a filter shows only its group" do
    get search_path(q: "villa", tipo: "personas")

    assert_select "[data-search-group]", count: 0
    get search_path(q: "villa", tipo: "estacas")
    assert_select "[data-search-group]", count: 1
  end

  test "inventory items only show up for whoever can open the inventory" do
    item = Inventory.create!(name: "Materiales").items.create!(name: "Marcadores", unit: "u")

    get search_path(q: "marcador")
    assert_select "[data-search-group='inventario'] a[href='#{inventory_item_path(item)}']"

    counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    sign_in_as(counselor)
    get search_path(q: "marcador")
    assert_select "[data-search-group='inventario']", false
    assert_select "[data-search-results]", text: /Sin resultados/
  end
end
