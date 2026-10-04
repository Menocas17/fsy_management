require "test_helper"

class NightAttendanceTest < ActiveSupport::TestCase
  setup do
    @branch = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 3, auxiliar_company: @branch)
    @juan = participants(:juan).tap { |joven| joven.update!(company: @company, room: "301") }
    @pedro = person("Pedro", "joven", "H", company: @company)
    @ana = person("Ana", "joven", "M", company: @company)
    @night = Date.new(2027, 1, 11)
  end

  test "the night runs from 6 pm to 6 am" do
    assert_equal @night, NightAttendance.current_night(Time.zone.local(2027, 1, 11, 21))
    assert_equal @night, NightAttendance.current_night(Time.zone.local(2027, 1, 12, 1, 30))
    assert_equal Date.new(2027, 1, 12), NightAttendance.current_night(Time.zone.local(2027, 1, 12, 7))
    assert_equal Date.new(2027, 1, 11)..Date.new(2027, 1, 15), NightAttendance.event_nights.first..NightAttendance.event_nights.last
  end

  test "each joven is marked present or absent with a reason, and every one must be marked" do
    list = NightAttendance.new(company: @company, night_on: @night, gender: "H")

    assert_not list.record({ @juan.id => { status: "presente" } }, taken_by: nil)
    assert_match "Falta marcar a Pedro", list.errors.full_messages.to_sentence

    assert_not list.record({ @juan.id => { status: "presente" }, @pedro.id => { status: "ausente", absence_reason: "otro" } }, taken_by: nil)
    assert_match "Pedro Prueba: escribe el motivo", list.errors.full_messages.to_sentence

    assert list.record({ @juan.id => { status: "presente" },
                         @pedro.id => { status: "ausente", absence_reason: "otro", absence_detail: "Con sus papás" } }, taken_by: nil)
    assert_equal 2, list.marks.count, "only the men: Ana is on the women's list"
    assert_equal "Con sus papás", list.mark_for(@pedro).reason_label
    assert_equal :ausentes, NightAttendance.status_for(list, [ @juan.id, @pedro.id ])

    assert list.reload.record({ @juan.id => { status: "presente" }, @pedro.id => { status: "presente", absence_detail: "x" } }, taken_by: nil)
    assert_nil list.mark_for(@pedro).absence_detail
    assert_equal :completa, NightAttendance.status_for(list, [ @juan.id, @pedro.id ])
    assert_equal :pendiente, NightAttendance.status_for(nil, [ @ana.id ])
  end

  test "before the event tonight is a test night; once it starts, only the event's nights" do
    before = Time.zone.local(2026, 10, 5, 20)
    assert NightAttendance.testing?(before)
    assert_equal [ Date.new(2026, 10, 5), *NightAttendance.event_nights ], NightAttendance.panel_nights(before)
    assert_equal Date.new(2026, 10, 5), NightAttendance.default_night(before)

    during = Time.zone.local(2027, 1, 13, 23)
    assert_not NightAttendance.testing?(during)
    assert_equal NightAttendance.event_nights, NightAttendance.panel_nights(during)
    assert_equal Date.new(2027, 1, 13), NightAttendance.default_night(during)
    assert_equal Date.new(2027, 1, 15), NightAttendance.default_night(Time.zone.local(2027, 2, 1, 12))
  end

  test "the 10 pm check sends one consolidated alert, once per night, to auxiliares, coordinators and directors" do
    NightAttendance.new(company: @company, night_on: @night, gender: "H")
                   .record({ @juan.id => { status: "presente" }, @pedro.id => { status: "ausente", absence_reason: "enfermeria" } }, taken_by: nil)
    other = Company.create!(number: 4)
    5.times { |i| person("Joven#{i}", "joven", "M", company: other) }

    assert_difference -> { Alert.count }, 1 do
      NightAttendanceNotifier.nightly_check(@night)
      NightAttendanceNotifier.nightly_check(@night)
    end

    alert = Alert.last
    assert_equal "Asistencia nocturna: 2 listas sin pasar y 1 joven ausente", alert.title
    assert_match "Compañía 3 · hombres: Pedro Prueba (Enfermería)", alert.body
    assert_match "Compañía 3 · mujeres: sin pasar", alert.body
    assert_match "Compañía 4 · mujeres: sin pasar", alert.body
    assert_equal %w[auxiliar coordinador director], alert.target_roles
    assert alert.source_asistencia?
  end

  test "no alert when every list is complete" do
    NightAttendance.new(company: @company, night_on: @night, gender: "H")
                   .record({ @juan.id => { status: "presente" }, @pedro.id => { status: "presente" } }, taken_by: nil)
    NightAttendance.new(company: @company, night_on: @night, gender: "M").record({ @ana.id => { status: "presente" } }, taken_by: nil)

    assert_no_difference -> { Alert.count } do
      NightAttendanceNotifier.nightly_check(@night)
    end
  end

  private
    def person(name, rol, gender, company: nil)
      Participant.create!(first_name: name, last_name: "Prueba", age: 17, stake: "bello_horizonte", ward: "la_rotonda",
                          shirt_number: "m", gender: gender, rol: rol, company: company)
    end
end
