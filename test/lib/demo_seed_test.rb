require "test_helper"

class DemoSeedTest < ActiveSupport::TestCase
  setup { DemoSeed.new(out: StringIO.new).run }

  test "builds the company structure, leadership and logistics team" do
    assert_equal (1..22).to_a, Company.by_number.pluck(:number)
    assert_equal [ 5, 5, 4, 4, 4 ], AuxiliarCompany.all.map { |auxiliar_company| auxiliar_company.companies.count }.sort.reverse
    assert_equal %w[salon_las_americas salon_nicaragua], Company.distinct.pluck(:dining_hall).sort
    refute_nil Company.find_by(number: 3).nickname

    Company.includes(:counselors).find_each do |company|
      assert_equal %w[H M], company.counselors.map(&:gender).sort, "#{company.name} needs one counselor of each gender"
      assert Participant.joven.where(company: company).count.between?(18, 22), "#{company.name} should have ~20 jóvenes"
    end

    coordinator_ids = Participant.coordinador.pluck(:id).sort
    assert_equal 2, coordinator_ids.size
    AuxiliarCompany.includes(:auxiliars).find_each do |auxiliar_company|
      assert_equal coordinator_ids, auxiliar_company.coordinators.map(&:id).sort
      assert_equal %w[H M], auxiliar_company.auxiliars.map(&:gender).sort
    end

    assert_equal 2, Participant.director.count
    assert_equal 1, Participant.director_logistica.count
    assert Participant.logistica.count.between?(16, 20)
    assert Participant.logistica.all? { |member| member.logistics_area.present? }
    assert_includes LogisticsArea.pluck(:name), "Tecnología"
  end

  test "replaces old data, re-links the owner as a counselor and adds a demo login per role" do
    refute Participant.exists?(first_name: "Juan", last_name: "Pérez")

    owner = User.find_by!(email_address: DemoSeed::OWNER_EMAIL).participant
    assert_equal "Rodolfo Jose Menocal Castillo", owner.full_name
    assert owner.consejero?
    assert_equal 3, owner.companies.first.number

    %w[director coordinador auxiliar consejero director-logistica logistica joven].each do |role|
      assert User.find_by(email_address: "demo.#{role}@example.com")&.participant, "missing demo login for #{role}"
    end
  end
end
