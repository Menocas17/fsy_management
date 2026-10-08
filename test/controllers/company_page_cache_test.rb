require "test_helper"

# La página de una compañía guarda en caché sus líderes y su lista de jóvenes (companies/show): con la caché
# encendida, como en producción, cualquier cambio se tiene que ver en la visita siguiente.
class CompanyPageCacheTest < ActionDispatch::IntegrationTest
  setup do
    @cache, @perform = Rails.cache, ActionController::Base.perform_caching
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    ActionController::Base.perform_caching = true

    sign_in_as(users(:one))
    @auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 3, auxiliar_company: @auxiliar_company)
    participants(:juan).update!(company: @company)
  end

  teardown do
    Rails.cache = @cache
    ActionController::Base.perform_caching = @perform
  end

  test "editing a joven shows on the next visit" do
    get company_path(@company)
    assert_select "[data-participant-row]", text: /#{participants(:juan).first_name}/

    travel 1.second
    participants(:juan).update!(first_name: "Renombrado")

    get company_path(@company)
    assert_select "[data-participant-row]", text: /Renombrado/
  end

  test "a joven joining or leaving shows on the next visit" do
    get company_path(@company)
    assert_select "[data-participant-row]", 1

    participants(:juan).update!(company: nil)

    get company_path(@company)
    assert_select "[data-participant-row]", 0
  end

  test "assigning a counselor or an auxiliar fills the leaders on the next visit" do
    get company_path(@company)
    assert_select "[data-leader-slot][data-vacant]", 4

    Membership.create!(associable: @company, participant: participants(:maria))
    get company_path(@company)
    assert_select "[data-leader-slot='consejero-#{participants(:maria).gender}']", text: /#{participants(:maria).full_name}/

    auxiliar = participants(:maria).dup.tap { |p| p.assign_attributes(first_name: "Aux", last_name: "Uno", rol: :auxiliar, gender: "H", code: nil) }
    auxiliar.save!(validate: false)
    Membership.create!(associable: @auxiliar_company, participant: auxiliar)
    get company_path(@company)
    assert_select "[data-leader-slot='auxiliar-H']", text: /Aux Uno/
  end

  test "a leader's new name shows on the next visit" do
    Membership.create!(associable: @company, participant: participants(:maria))
    get company_path(@company)

    travel 1.second
    participants(:maria).update!(first_name: "Mariela")

    get company_path(@company)
    assert_select "[data-leader-slot]", text: /Mariela/
  end
end
