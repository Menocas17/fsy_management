require "test_helper"

class EventSeedTest < ActiveSupport::TestCase
  test "replaces everything with the test files, already staffed and with every joven in a company" do
    admin = User.create!(email_address: "admin@example.com", password: "Una-clave-larga-123", superadmin: true, participant: participants(:juan))
    areas = %w[Finanzas Registro Alimentación].map { |name| LogisticsArea.create!(name: name) }
    assert_equal [ "Enfermería" ], EventSeed.missing_areas
    areas << LogisticsArea.create!(name: "Enfermeria", nursing: true)
    assert_empty EventSeed.missing_areas

    EventSeed.new(out: StringIO.new).run

    assert_nil admin.reload.participant_id
    assert_equal areas.map(&:id).sort, LogisticsArea.ids.sort, "the areas stay as they were"
    assert_equal({ "director" => 2, "coordinador" => 2, "director_logistica" => 2, "auxiliar" => 10, "logistica" => 15,
                   "consejero" => 50, "joven" => 512 }, Participant.group(:rol).count)
    assert_equal 4, Participant.logistica.where(logistics_area: areas.last).count

    assert_equal 25, Company.count
    assert Company.all.all?(&:staff_complete?), "every company has its two counselors"
    assert_equal 5, AuxiliarCompany.count
    AuxiliarCompany.find_each do |auxiliar_company|
      assert_equal 2, auxiliar_company.auxiliars.count
      assert_equal %w[H M], auxiliar_company.coordinators.map(&:gender)
    end

    assert_equal 0, Participant.joven.where(company_id: nil).count
    assert_equal [ 20, 21 ], Company.jovenes_counts.values.minmax
    assert_equal 0, Participant.joven.where(room: nil).count
    assert Participant.consejero.all? { |counselor| counselor.room.present? }
    assert Participant.joven.with_medical_note(:emotional_information).exists?
  end
end
