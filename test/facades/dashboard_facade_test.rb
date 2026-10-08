require "test_helper"

class DashboardFacadeTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(number: 7)
    participants(:juan).update!(company: @company)
    Membership.create!(associable: @company, participant: participants(:maria))
  end

  def kpis_for(participant)
    user = User.new(email_address: "x@fsy.com", participant: participant)
    DashboardFacade.new(user: user).simple_kpis.index_by { |kpi| kpi[:label] }
  end

  test "a counselor sees their jóvenes, who is in the infirmary and last night's attendance" do
    InfirmaryVisit.admit_directly(participants(:juan), by: nil, reason: :fiebre).start
    travel_to Time.zone.local(2027, 1, 12, 10) do
      night = Date.new(2027, 1, 11)
      attendance = NightAttendance.new(company: @company, gender: :H, night_on: night, taken_by_name: "María", confirmed_at: Time.current)
      attendance.marks.build(participant: participants(:juan), status: :presente)
      attendance.save!

      kpis = kpis_for(participants(:maria))
      assert_equal 1, kpis["Mis jóvenes"][:value]
      assert_equal 1, kpis["Enfermería"][:value]
      assert_equal 1, kpis["Asistencia"][:value]
      assert_equal "de 1 · anoche", kpis["Asistencia"][:sub]
    end
  end

  test "attendance reads as not taken when nobody passed the list" do
    kpis = kpis_for(participants(:maria))
    assert_equal "—", kpis["Asistencia"][:value]
    assert_equal "Sin pasar", kpis["Asistencia"][:sub]
  end

  test "logística sees the figures of its area's flag" do
    member = participants(:maria).dup
    member.update!(rol: :logistica, first_name: "Luis", logistics_area: LogisticsArea.create!(name: "Registro", checkin: true))
    Checkin.register(participant: participants(:juan), recorded_by: nil)

    kpis = kpis_for(member)
    assert_equal [ "Llegaron", "Por llegar", "Mi equipo" ], kpis.keys
    assert_equal 1, kpis["Llegaron"][:value]
    assert_equal 0, kpis["Por llegar"][:value]

    member.logistics_area.update!(checkin: false, nursing: true)
    assert_equal [ "Adentro", "En camino", "Atendidos" ], kpis_for(member).keys
  end

  test "direction and the superadmin see the whole event" do
    assert_equal [ "Jóvenes", "Staff", "Enfermería" ], DashboardFacade.new(user: users(:one)).simple_kpis.map { |kpi| kpi[:label] }
  end
end
