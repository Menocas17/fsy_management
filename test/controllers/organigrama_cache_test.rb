require "test_helper"

# El organigrama general va en caché (organigrama/show): con la caché encendida, como en producción, un
# cambio de personas o de compañías se ve en la visita siguiente.
class OrganigramaCacheTest < ActionDispatch::IntegrationTest
  setup do
    @cache, @perform, @fragments = Rails.cache, ActionController::Base.perform_caching, ActionController::Base.cache_store
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    # Los fragmentos de las vistas van a la caché del controlador, no a Rails.cache (ver company_page_cache_test).
    ActionController::Base.cache_store = Rails.cache
    ActionController::Base.perform_caching = true
    sign_in_as(users(:one))
    @auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(name: "Alfa 3", auxiliar_company: @auxiliar_company)
  end

  teardown do
    Rails.cache = @cache
    ActionController::Base.cache_store = @fragments
    ActionController::Base.perform_caching = @perform
  end

  test "a new counselor, a renamed person and a new joven show on the next visit" do
    get organigrama_path
    assert_not_includes response.body, "María García"

    @company.memberships.create!(participant: participants(:maria))
    get organigrama_path
    assert_includes response.body, "María García"

    travel 1.second
    participants(:maria).update!(first_name: "Mariela")
    get organigrama_path
    assert_includes response.body, "Mariela García"

    # El reloj de la prueba está congelado: sin avanzarlo, esta edición cae en el mismo instante que la anterior.
    travel 1.second
    participants(:juan).update!(company: @company)
    get organigrama_path
    assert_select "[data-company-id='#{@company.id}'] [data-jovenes-count='1']"
  end

  test "renaming a company or adding an auxiliary one shows on the next visit" do
    get organigrama_path

    travel 1.second
    @company.update!(name: "Alfa Renombrada")
    AuxiliarCompany.create!(name: "Auxiliar Beta")
    get organigrama_path
    assert_includes response.body, "Alfa Renombrada"
    assert_includes response.body, "Auxiliar Beta"
  end
end
