require "test_helper"

class AuxiliarCompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    create_staff("Marta", "coordinador", "M")
    @auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 1, nickname: "Luz del Mundo", auxiliar_company: @auxiliar_company)
    @company.memberships.create!(participant: participants(:maria))
    participants(:juan).update!(company: @company)
    @auxiliar = create_staff("Luis", "auxiliar", "H")
    @auxiliar_company.memberships.create!(participant: @auxiliar)
  end

  test "index cards count the counselors and jóvenes of the auxiliary company's companies" do
    get auxiliar_companies_path

    assert_response :success
    card = css_select("[data-auxiliar-company-card='Auxiliar Alfa']").first.text.squish
    assert_includes card, "1 Compañías 1/2 Consejeros 1 Jóvenes"
    assert_includes card, "Luis Prueba"
    assert_includes card, "Falta auxiliar"
  end

  test "show lists its companies, coordination and auxiliares" do
    get auxiliar_company_path(@auxiliar_company)

    assert_response :success
    assert_select "h1", "Auxiliar Alfa"
    assert_select "[data-company-card='1']", text: /Luz del Mundo/
    assert_select "[data-leader-slot='auxiliar-H']", text: /Luis Prueba/
    assert_select "[data-leader-slot='auxiliar-M'][data-vacant]"
    assert_includes response.body, "Marta Prueba"
    assert_includes response.body, "1 de 2 consejeros"
  end

  test "edit offers only auxiliares that fill the vacant slot and records the assignment" do
    free_woman = create_staff("Ana", "auxiliar", "M")
    create_staff("Pedro", "auxiliar", "H")

    get edit_auxiliar_company_path(@auxiliar_company)

    assert_response :success
    assert_select "select#participant_id option[value='#{free_woman.id}']"
    assert_select "select#participant_id option", text: /Pedro Prueba/, count: 0

    post assign_staff_auxiliar_company_path(@auxiliar_company), params: { participant_id: free_woman.id }
    assert_redirected_to edit_auxiliar_company_path(@auxiliar_company, anchor: "lideres")
    assert_equal "Asignó a Ana Prueba en la compañía auxiliar Auxiliar Alfa", AuditLog.recent.first.summary
  end

  test "the form doesn't ask for coordinators: both look after every auxiliary company" do
    create_staff("Iván", "coordinador", "H")

    get edit_auxiliar_company_path(@auxiliar_company)
    assert_select "select[name*=coordinator]", 0

    get auxiliar_company_path(@auxiliar_company)
    assert_includes response.body, "Iván Prueba"
  end

  test "deleting keeps its companies, now without an auxiliary company" do
    delete auxiliar_company_path(@auxiliar_company)

    assert_redirected_to auxiliar_companies_path
    assert_nil @company.reload.auxiliar_company_id
  end

  test "counselors can't create or delete auxiliary companies" do
    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get new_auxiliar_company_path
    assert_redirected_to companies_path

    assert_no_difference -> { AuxiliarCompany.count } do
      delete auxiliar_company_path(@auxiliar_company)
    end
  end

  private
    def create_staff(first_name, rol, gender)
      Participant.create!(first_name: first_name, last_name: "Prueba", age: 30, stake: "las_americas",
                          shirt_number: "m", gender: gender, rol: rol)
    end
end
