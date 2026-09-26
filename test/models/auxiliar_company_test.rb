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

  test "sees the counselors and jóvenes of its companies" do
    company = Company.create!(number: 1, auxiliar_company: @auxiliar_company)
    company.memberships.create!(participant: participants(:maria))
    participants(:juan).update!(company: company)

    assert_equal [ participants(:maria) ], @auxiliar_company.counselors.to_a
    assert_equal [ participants(:juan) ], @auxiliar_company.jovenes.to_a
  end

  test "an auxiliar's scope covers the companies of their auxiliary company" do
    company = Company.create!(number: 1, auxiliar_company: @auxiliar_company)
    company.memberships.create!(participant: participants(:maria))
    auxiliar = Participant.create!(first_name: "Luis", last_name: "Prueba", age: 30, stake: "bello_horizonte",
                                   shirt_number: "m", gender: "H", rol: "auxiliar")
    @auxiliar_company.memberships.create!(participant: auxiliar)

    assert_equal [ company ], auxiliar.auxiliar_scope[:companies]
    assert_equal [ participants(:maria) ], auxiliar.auxiliar_scope[:counselors]
  end

  test "labels its company numbers as a range and its badge initial" do
    [ 3, 1, 2 ].each { |number| Company.create!(number: number, auxiliar_company: @auxiliar_company) }

    assert_equal "1–3", @auxiliar_company.reload.company_numbers_label
    assert_equal "A", @auxiliar_company.initial
  end

  test "both coordinator slots can't hold the same person" do
    @auxiliar_company.second_coordinator = @first

    assert_not @auxiliar_company.valid?
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
