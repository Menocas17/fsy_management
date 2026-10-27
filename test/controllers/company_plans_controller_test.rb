require "test_helper"

class CompanyPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @first = Company.create!(number: 1)
    @second = Company.create!(number: 2)
    participants(:juan).update_column(:company_id, @second.id)
    @joven = Participant.create!(first_name: "Ana", last_name: "Paz", age: 15, shirt_number: "m", gender: "M", rol: "joven",
                                 stake: "bello_horizonte", ward: "la_rotonda")
  end

  test "full access sees the proposal and applies it" do
    sign_in_as(users(:one))

    get company_plan_path
    assert_response :success
    assert_select "[data-plan-company='1']"
    assert_select "[data-company-plan-action='aplicar']"

    assert_difference -> { AuditLog.where(category: :companias).count }, 1 do
      post company_plan_path, params: { huella: CompanyPlanner.fingerprint }
    end
    assert_redirected_to companies_path
    assert_equal @first.id, @joven.reload.company_id
  end

  test "rebuilding asks how many companies and creates the missing ones" do
    sign_in_as(users(:one))

    get company_plan_path(modo: "todos", companias: 3)
    assert_response :success
    assert_select "input[name=companias][value='3']"
    assert_select "[data-plan-company='3']", text: /Nueva/

    assert_difference -> { Company.count }, 1 do
      post company_plan_path, params: { modo: "todos", companias: 3, huella: CompanyPlanner.fingerprint }
    end
  end

  test "if something changed since the preview, it shows the new one instead of applying" do
    sign_in_as(users(:one))

    post company_plan_path, params: { huella: "vieja" }
    assert_redirected_to company_plan_path
    assert_nil @joven.reload.company_id
  end

  test "without full access it is closed" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get company_plan_path
    assert_redirected_to companies_path
    post company_plan_path, params: { huella: CompanyPlanner.fingerprint }
    assert_nil @joven.reload.company_id
  end
end
