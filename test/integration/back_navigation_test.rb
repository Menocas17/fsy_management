require "test_helper"

# El botón de volver regresa a la página de donde se vino, con su nombre, no a una lista fija.
class BackNavigationTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @company = Company.create!(number: 3)
    @juan = participants(:juan).tap { |joven| joven.update!(company: @company) }
  end

  test "company → joven → company → back walks the same way back" do
    get company_path(@company, return_to: companies_path)
    joven_link = css_select("a[href^='#{participant_path(@juan)}']").first["href"]

    get joven_link
    assert_select "a[title='Volver a Compañía 3'][href='#{company_path(@company, return_to: companies_path)}']"
    company_link = css_select("main a[href^='#{company_path(@company)}?return_to=']").find { |a| a["title"].nil? && a.text.strip == "Compañía 3" }["href"] # el de la ficha, no el de volver

    get company_link
    back = css_select("a[title='Volver a Juan']").first
    assert back, "the company goes back to Juan"
    get back["href"]
    assert_response :success
    assert_equal participant_path(@juan), request.path
  end

  test "without a return_to the pages keep their usual way back" do
    get participant_path(@juan)
    assert_select "a[title='Volver a Jóvenes'][href='#{participants_path}']"
    get company_path(@company)
    assert_select "a[title='Volver a Compañías'][href='#{companies_path}']"
  end
end
