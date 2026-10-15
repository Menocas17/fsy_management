require "test_helper"

class CompanySuggesterTest < ActiveSupport::TestCase
  setup do
    @young = Company.create!(number: 1)
    @older = Company.create!(number: 2)
    @also_older = Company.create!(number: 3)
    2.times { joven(@young, 14, "M") }
    2.times { joven(@young, 14, "H") }
    2.times { joven(@older, 17, "M") }
    2.times { joven(@older, 17, "H") }
    2.times { joven(@also_older, 17, "M") }
    2.times { joven(@also_older, 17, "H") }
  end

  test "age weighs the most" do
    assert_equal @young, suggest(age: 14, gender: "M").first.company
    assert_equal @older, suggest(age: 17, gender: "M").first.company
    assert_equal "Edades de 14 años", suggest(age: 14, gender: "M").first.reasons.first.text
  end

  test "among companies of their age, the one short of their gender wins" do
    joven(@older, 17, "H")
    assert_equal @older, suggest(age: 17, gender: "M").first.company
    assert_equal @also_older, suggest(age: 17, gender: "H").first.company
  end

  test "fewer people from their ward, and no counselor from their ward" do
    joven(@older, 17, "M", ward: "ducuali")
    assert_equal @also_older, suggest(age: 17, gender: "M", ward: "ducuali").first.company

    counselor = Participant.create!(first_name: "Con", last_name: "Sejero", age: 30, shirt_number: "m", gender: "H", rol: "consejero",
                                    stake: "bello_horizonte", ward: "ciudad_jardin", company: @also_older)
    top = suggest(age: 17, gender: "M", ward: "ciudad_jardin").first
    assert_equal @older, top.company
    reasons = suggest(age: 17, gender: "M", ward: "ciudad_jardin", limit: 3).map { |suggestion| suggestion.reasons.map(&:text) }.flatten
    assert_includes reasons, "#{counselor.first_name}, consejero de su barrio"
  end

  test "without age nor gender there is nothing to suggest" do
    assert_empty suggest(age: nil, gender: nil)
  end

  private
    def suggest(age:, gender:, ward: nil, limit: 3)
      CompanySuggester.new(age: age, gender: gender, ward: ward).call(limit: limit)
    end

    def joven(company, age, gender, ward: "la_rotonda")
      Participant.create!(first_name: "J", last_name: "P", age: age, shirt_number: "m", gender: gender, rol: "joven",
                          stake: "bello_horizonte", ward: ward, company: company)
    end
end
