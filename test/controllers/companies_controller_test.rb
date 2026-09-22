require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 3, nickname: "Guerreros de Helamán", dining_hall: :salon_nicaragua, auxiliar_company: @auxiliar_company)
  end

  test "index lists the companies as cards in number order" do
    Company.create!(number: 10)
    Company.create!(number: 2)

    get companies_path

    assert_response :success
    assert_equal %w[2 3 10], css_select("[data-company-card]").map { |card| card["data-company-card"] }
    assert_select "[data-company-card='3']", text: /Guerreros de Helamán/
    assert_select "[data-company-card='10']", text: /Sin nombre elegido/
  end

  test "index search matches the chosen name, the number and counselors" do
    Company.create!(number: 4, nickname: "Roca Firme")
    @company.memberships.create!(participant: participants(:maria))

    get companies_path(query: "roca")
    assert_equal %w[4], css_select("[data-company-card]").map { |card| card["data-company-card"] }

    get companies_path(query: "3")
    assert_equal %w[3], css_select("[data-company-card]").map { |card| card["data-company-card"] }

    get companies_path(query: "María García")
    assert_equal %w[3], css_select("[data-company-card]").map { |card| card["data-company-card"] }
  end

  test "show presents the profile with leaders, rooms and its jóvenes" do
    @company.memberships.create!(participant: participants(:maria))
    participants(:juan).update!(company: @company, room: "301")

    get company_path(@company)

    assert_response :success
    assert_select "h1", "Compañía 3"
    assert_select "[data-company-nickname]", "Guerreros de Helamán"
    assert_select "[data-leader-slot='consejero-M']", text: /María García/
    assert_select "[data-leader-slot='consejero-H'][data-vacant]"
    assert_select "[data-room='301']", text: /1 jóv/
    assert_select "turbo-frame#company_participants [data-participant-row]", text: /Juan Pérez/
    assert_includes response.body, "Salón Nicaragua"
  end

  test "creating a company takes its name from the number and records who did it" do
    assert_difference -> { AuditLog.companias.count }, 1 do
      post companies_path, params: { company: { number: 9, nickname: "Roca Firme" } }
    end

    company = Company.find_by!(number: 9)
    assert_redirected_to company
    assert_equal "Compañía 9", company.name
    assert_equal "Creó Compañía 9", AuditLog.recent.first.summary
  end

  test "updating edits the chosen name and comedor but never the number" do
    patch company_path(@company), params: { company: { number: 99, nickname: "Luz del Mundo", dining_hall: "salon_las_americas" } }

    @company.reload
    assert_equal [ 3, "Compañía 3", "Luz del Mundo" ], [ @company.number, @company.name, @company.nickname ]
    assert @company.salon_las_americas?
    assert_equal "Actualizó nombre elegido y comedor de Compañía 3", AuditLog.recent.first.summary

    assert_no_difference -> { AuditLog.count } do
      patch company_path(@company), params: { company: { nickname: "Luz del Mundo" } }
    end
  end

  test "edit locks the number and offers only counselors that fill a vacant slot" do
    @company.memberships.create!(participant: participants(:maria))
    free_man = create_counselor("Pedro", "H")
    create_counselor("Ana", "M")

    get edit_company_path(@company)

    assert_response :success
    assert_select "[data-locked-number]", text: /Compañía 3/
    assert_select "input[name='company[number]']", 0
    assert_select "select#participant_id option[value='#{free_man.id}']"
    assert_select "select#participant_id option", text: /Ana Libre/, count: 0
    assert_select "[data-leader-slot='consejero-M'] button", text: "Quitar"
  end

  test "assigning and removing counselors are recorded and return to the edit page" do
    post assign_staff_company_path(@company), params: { participant_id: participants(:maria).id }
    assert_redirected_to edit_company_path(@company, anchor: "lideres")
    assert_equal "Asignó a María García como consejero en Compañía 3", AuditLog.recent.first.summary

    delete remove_staff_company_path(@company, membership_id: @company.memberships.first.id)
    assert_redirected_to edit_company_path(@company, anchor: "lideres")
    assert_equal "Removió a María García de Compañía 3", AuditLog.recent.first.summary
  end

  test "overview charts jóvenes by company and gender and by dining hall" do
    participants(:juan).update!(company: @company, room: "301")
    @company.memberships.create!(participant: participants(:maria))

    get overview_companies_path

    assert_response :success
    stacked = css_select("[data-chart-kind-value='stacked']").first
    assert_includes stacked["aria-label"], "Compañía 3: 1 hombres y 0 mujeres"
    assert_select "[data-chart-kind-value='donut'][aria-label*='Salón Nicaragua: 1']"
    assert_select "[data-overview-row='3']", text: /1\/2.*1.*1 \/ 0/m
    assert_select "[data-overview-kpi='consejeros-asignados']", "1/2"
  end

  test "deleting a company leaves its jóvenes without a company" do
    participants(:juan).update!(company: @company)

    delete company_path(@company)

    assert_redirected_to companies_path
    assert_nil participants(:juan).reload.company_id
  end

  test "counselors can't create or delete companies" do
    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))
    @company.memberships.create!(participant: participants(:maria))

    get new_company_path
    assert_redirected_to companies_path

    assert_no_difference -> { Company.count } do
      delete company_path(@company)
    end
  end

  private
    def create_counselor(first_name, gender)
      Participant.create!(first_name: first_name, last_name: "Libre", age: 22, stake: "villa_flor",
                          shirt_number: "m", gender: gender, rol: "consejero")
    end
end
