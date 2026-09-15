require "test_helper"

class OrganigramaControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @director = create_participant("Roberto", "director", "H")
    @coordinator = create_participant("Marta", "coordinador", "M")
    @second_coordinator = create_participant("Iván", "coordinador", "H")
    @auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa", coordinator: @coordinator, second_coordinator: @second_coordinator)
    @company = Company.create!(name: "Alfa 3", auxiliar_company: @auxiliar_company)
    @company.memberships.create!(participant: participants(:maria))
    participants(:juan).update!(company: @company)
    Company.create!(name: "Compañía Suelta")
    create_participant("Lucía", "director_logistica", "M")
    create_participant("Sergio", "logistica", "H", logistics_area: LogisticsArea.create!(name: "Tecnología"))
  end

  test "general view renders the whole hierarchy from real records" do
    get organigrama_path

    assert_response :success
    [ "Roberto Prueba", "Auxiliar Alfa", "Marta Prueba", "Iván Prueba", "Alfa 3", "María García", "Compañía Suelta", "Lucía Prueba", "Sergio Prueba" ].each do |text|
      assert_includes response.body, text
    end
    assert_select "[data-company-id='#{@company.id}'] [data-jovenes-count='1']"
    assert_select "[data-logistics-area='Tecnología']", text: /Sergio Prueba/
    assert_select "a[href='#{participants_path(company: "Alfa 3")}']", text: /Ver participantes/
  end

  test "mi compañía narrows to the signed-in counselor's chain" do
    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get organigrama_path(scope: "mi_compania")

    assert_response :success
    assert_includes response.body, "Alfa 3"
    assert_includes response.body, "Auxiliar Alfa"
    assert_includes response.body, "Roberto Prueba"
    refute_includes response.body, "Compañía Suelta"
    refute_includes response.body, "Sergio Prueba"
  end

  test "mi compañía works for the second coordinator too" do
    sign_out
    sign_in_as(User.create!(email_address: "ivan@fsy.com", password: "Coordina1!", participant: @second_coordinator))

    get organigrama_path(scope: "mi_compania")

    assert_includes response.body, "Alfa 3"
    refute_includes response.body, "Compañía Suelta"
  end

  test "mi compañía works for a joven through their assigned company" do
    sign_out
    sign_in_as(User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan)))

    get organigrama_path(scope: "mi_compania")

    assert_includes response.body, "Alfa 3"
    refute_includes response.body, "Compañía Suelta"
  end

  test "mi compañía explains when the account has no company" do
    get organigrama_path(scope: "mi_compania")

    assert_response :success
    assert_includes response.body, "no está asignada a ninguna compañía"
  end

  private

  def create_participant(first_name, rol, gender, **attributes)
    Participant.create!(first_name: first_name, last_name: "Prueba", age: 40, stake: "bello_horizonte",
                        ward: "la_rotonda", shirt_number: "m", gender: gender, rol: rol, **attributes)
  end
end
