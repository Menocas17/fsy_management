require "test_helper"

class AuxiliarCompanyTest < ActiveSupport::TestCase
  setup do
    @first = create_coordinator("Marta", "M")
    @second = create_coordinator("Iván", "H")
    @auxiliar_company = AuxiliarCompany.create!(name: "Auxiliar Alfa", coordinator: @first, second_coordinator: @second)
  end

  test "lists and names both coordinators" do
    assert_equal [ @first, @second ], @auxiliar_company.coordinators
    assert_equal "Marta Prueba y Iván Prueba", @auxiliar_company.coordinator_name
  end

  test "is found for either coordinator" do
    assert_includes AuxiliarCompany.for_coordinator(@first), @auxiliar_company
    assert_includes AuxiliarCompany.for_coordinator(@second), @auxiliar_company
  end

  test "names the gap when nobody coordinates it" do
    assert_equal "Sin coordinador", AuxiliarCompany.new(name: "Auxiliar Beta").coordinator_name
  end

  private
    def create_coordinator(first_name, gender)
      Participant.create!(first_name: first_name, last_name: "Prueba", age: 40, stake: "bello_horizonte",
                          shirt_number: "m", gender: gender, rol: "coordinador")
    end
end
