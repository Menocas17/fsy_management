require "test_helper"

class CompanySuggestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(number: 4)
    Participant.create!(first_name: "Ya", last_name: "Está", age: 15, shirt_number: "m", gender: "H", rol: "joven",
                        stake: "bello_horizonte", ward: "la_rotonda", company: @company)
    @walk_in = participants(:juan).tap { |joven| joven.update!(age: 15, company: nil) }
    @registrar = person("Rita", "logistica", "M", logistics_area: LogisticsArea.create!(name: "Registro", checkin: true))
  end

  test "the registration form asks with what is typed and offers to choose" do
    sign_in_as account(@registrar)

    get company_suggestions_path(fecha: 15.years.ago.to_date.strftime("%d/%m/%Y"), genero: "M", barrio: "ducuali")
    assert_response :success
    assert_select "turbo-frame#company_suggestions [data-company-suggestion='4']", text: /Le faltan mujeres/
    assert_select "button[data-action='company-suggest#choose'][data-company-suggest-id-param='#{@company.id}']"

    get new_participant_path
    assert_select "turbo-frame#company_suggestions[data-company-suggest-target=frame]"
  end

  test "a walk-in's profile suggests companies and assigns one" do
    sign_in_as account(@registrar)

    get participant_path(@walk_in)
    assert_select "[data-profile-company-suggestions] turbo-frame[src*='modo=ficha']"

    get company_suggestions_path(participant_id: @walk_in.id, modo: "ficha")
    assert_select "form[action='#{participant_path(@walk_in)}'] input[name='participant[company_id]'][value='#{@company.id}']"

    patch participant_path(@walk_in), params: { participant: { company_id: @company.id } }
    assert_equal @company, @walk_in.reload.company
  end

  test "who can't place a joven in a company doesn't get suggestions" do
    counselor = person("Carlos", "consejero", "H")
    sign_in_as account(counselor)

    get company_suggestions_path(fecha: "01/01/2010", genero: "M")
    assert_response :forbidden
    get participant_path(@walk_in)
    assert_select "[data-profile-company-suggestions]", 0
  end

  private
    def person(name, rol, gender, **attrs)
      Participant.create!(first_name: name, last_name: "Prueba", age: 30, stake: "bello_horizonte", ward: "la_rotonda",
                          shirt_number: "m", gender: gender, rol: rol, **attrs)
    end

    def account(participant)
      User.create!(email_address: "#{participant.first_name.downcase}@fsy.com", password: "Prueba123!", participant: participant)
    end
end
