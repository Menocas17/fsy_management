require "test_helper"

class CompanyPlannerTest < ActiveSupport::TestCase
  WARDS = %w[bello_horizonte ciudad_jardin ducuali la_maximo_jerez la_rotonda primavera waspan].freeze

  setup do
    @first, @second, @third = (1..3).map { |number| Company.create!(number: number) }
    # El joven de los fixtures, de 20 años, ya en una compañía: que no cuente como pendiente.
    participants(:juan).update_column(:company_id, @third.id)
  end

  test "pending mode places only the jóvenes without company, where the suggester would, without moving anyone" do
    2.times { |index| joven(14, %w[M H][index], company: @first) }
    2.times { |index| joven(17, %w[M H][index], company: @second) }
    young = joven(14, "M")
    older = joven(17, "H")

    plan = CompanyPlanner.new.call
    assert_equal [ young.id, older.id ].sort, plan.moves.map { |member, _| member.id }.sort, "nobody with a company moves"
    assert_equal({ young.id => @first, older.id => @second }, plan.moves.to_h { |member, bucket| [ member.id, bucket.company ] })

    assert_equal 2, plan.apply!
    assert_equal [ @first.id, @second.id ], [ young.reload.company_id, older.reload.company_id ]
  end

  test "pending mode keeps companies even: a full company of their age gives way to another" do
    3.times { joven(15, "M", company: @first) }
    newcomers = Array.new(3) { joven(15, "M") }

    plan = CompanyPlanner.new.call
    cap = (Participant.joven.count / 3.0).ceil
    assert plan.buckets.all? { |bucket| bucket.size <= cap }
    assert_equal 3, plan.moves.size
    refute(plan.moves.any? { |_, bucket| bucket.company == @first }, "the first is already full")
    assert newcomers.all? { |joven| plan.moves.map { |member, _| member.id }.include?(joven.id) }
  end

  test "rebuilding groups by age, balances men and women and spreads each ward" do
    [ 14, 14, 15, 15, 16, 16, 17, 17, 18, 18 ].each_with_index do |age, index|
      joven(age, "M", ward: WARDS[index % 3])
      joven(age, "H", ward: WARDS[(index + 1) % 3])
    end

    plan = CompanyPlanner.new(mode: "todos", companies: 3).call
    assert_equal 3, plan.buckets.size
    created = plan.buckets.map { |bucket| bucket.members.reject { |member| member.id == participants(:juan).id } }
    assert created.all? { |members| (members.count { _1.gender == "M" } - members.count { _1.gender == "H" }).abs <= 1 }
    ranges = plan.buckets.map { |bucket| bucket.age_range.then { |low, high| high - low } }
    assert_operator ranges.first(2).max, :<=, 2, "companies of similar ages, the youngest first"
    assert_operator plan.buckets.first.age_range.last, :<=, plan.buckets.last.age_range.first

    seeded = CompanyPlanner.new(mode: "todos", companies: 3, seed: 7).call
    assert_equal seeded.buckets.map { |b| b.members.map(&:id) }, CompanyPlanner.new(mode: "todos", companies: 3, seed: 7).call.buckets.map { |b| b.members.map(&:id) },
                 "the same seed gives the same proposal"
  end

  test "rebuilding keeps jóvenes away from a counselor of their ward when it can" do
    Participant.create!(first_name: "Con", last_name: "Sejero", age: 30, shirt_number: "m", gender: "H", rol: "consejero",
                        stake: "bello_horizonte", ward: "ducuali", company: @first)
    6.times { |index| joven(15, %w[M H][index % 2], ward: index < 2 ? "ducuali" : "primavera") }

    plan = CompanyPlanner.new(mode: "todos", companies: 3).call
    assert_equal 0, plan.counselor_ward_conflicts
  end

  test "asking for more companies creates the missing ones after the last number; fewer leaves the rest empty" do
    4.times { |index| joven(15, %w[M H][index % 2]) }

    plan = CompanyPlanner.new(mode: "todos", companies: 5).call
    assert_equal [ 4, 5 ], plan.new_companies.map(&:number)
    assert_difference -> { Company.count }, 2 do
      plan.apply!
    end

    plan = CompanyPlanner.new(mode: "todos", companies: 2).call
    assert_equal [ 1, 2 ], plan.buckets.map(&:number)
    assert_match "quedan sin jóvenes", plan.warnings.first
  end

  test "without companies, pending mode says so and proposes nothing" do
    Participant.joven.update_all(company_id: nil)
    Company.delete_all
    joven(15, "M")

    plan = CompanyPlanner.new.call
    assert_empty plan.buckets
    assert_match "Todavía no hay compañías", plan.warnings.first
  end

  test "the fingerprint changes when a joven changes company" do
    joven = joven(15, "M")
    before = CompanyPlanner.fingerprint
    joven.update_column(:company_id, @first.id)
    refute_equal before, CompanyPlanner.fingerprint
  end

  private
    def joven(age, gender, ward: "la_rotonda", company: nil)
      Participant.create!(first_name: "J#{SecureRandom.hex(3)}", last_name: "P", age: age, shirt_number: "m", gender: gender,
                          rol: "joven", stake: "bello_horizonte", ward: ward, company: company)
    end
end
