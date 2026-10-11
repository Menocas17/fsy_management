require "application_system_test_case"

class CompanySuggestionsTest < ApplicationSystemTestCase
  test "registering a walk-in, the form suggests companies and «Elegir» fills the company" do
    young = Company.create!(number: 1)
    older = Company.create!(number: 2)
    { young => 14, older => 17 }.each do |company, age|
      Participant.create!(first_name: "J#{age}", last_name: "P", age: age, shirt_number: "m", gender: "H", rol: "joven",
                          stake: "bello_horizonte", ward: "la_rotonda", company: company)
    end
    sign_in_as users(:one)

    visit new_participant_path
    select "Mujer", from: "Género"
    fill_in "Fecha de nacimiento", with: (17.years.ago.to_date - 30).strftime("%d/%m/%Y")
    find_field("Fecha de nacimiento").send_keys(:tab)

    within "turbo-frame#company_suggestions" do
      assert_selector "[data-company-suggestion]", count: 2
      assert_selector "[data-company-suggestion]:first-child", text: /Compañía 2.*Le faltan mujeres/m
      first(:button, "Elegir").click
    end
    assert_equal older.id, find_field("Compañía").value
    assert_no_selector "turbo-frame#company_suggestions", visible: true
  end
end
