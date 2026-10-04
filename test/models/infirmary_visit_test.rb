require "test_helper"

class InfirmaryVisitTest < ActiveSupport::TestCase
  setup do
    @branch = AuxiliarCompany.create!(name: "Auxiliar Alfa")
    @company = Company.create!(number: 3, auxiliar_company: @branch)
    @juan = participants(:juan).tap { |joven| joven.update!(company: @company) }
    @counselor = person("Carlos", "consejero", "H")
    @company.memberships.create!(participant: @counselor)
    @auxiliar = person("Laura", "auxiliar", "M")
    @branch.memberships.create!(participant: @auxiliar)
    @nurse = person("Patricia", "logistica", "M", logistics_area: LogisticsArea.create!(name: "Enfermería", nursing: true))
    @other_counselor = person("Otro", "consejero", "M")
    Company.create!(number: 4).memberships.create!(participant: @other_counselor)
  end

  test "a counselor's notice waits on the way and alerts nobody until nursing confirms the arrival" do
    visit = InfirmaryVisit.announce(@juan, by: @counselor, reason: "fiebre")
    assert_no_difference -> { Alert.count } do
      assert visit.start
    end
    assert visit.en_camino?

    assert_difference -> { Alert.count }, 1 do
      visit.admit!(by: @nurse)
    end
    alert = Alert.last
    assert alert.audience_personas?
    assert alert.source_enfermeria?
    assert_equal [ @counselor.id, @auxiliar.id ].sort, alert.recipient_ids.sort
    assert_equal "Juan Pérez está en enfermería", alert.title
    assert_includes Alert.visible_to(@counselor), alert
    assert_includes Alert.visible_to(@auxiliar), alert
    assert_not_includes Alert.visible_to(@other_counselor), alert, "only the joven's own carers hear about it"
  end

  test "nursing admits directly and a joven has one open visit at a time" do
    assert_difference -> { Alert.count }, 1 do
      assert InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "lesion").start
    end

    second = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "malestar")
    assert_not second.start
    assert_includes second.errors.full_messages, "Juan Pérez ya está en enfermería"
  end

  test "leaving only alerts when the joven goes home or to the hospital" do
    back = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "malestar").tap(&:start)
    assert_no_difference -> { Alert.count } do
      assert back.discharge(by: @nurse, disposition: "regreso")
    end

    hospital = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "lesion").tap(&:start)
    assert_difference -> { Alert.count }, 1 do
      assert hospital.discharge(by: @nurse, disposition: "hospital", notes: "Posible fractura")
    end
    assert Alert.last.priority_critica?
    assert_equal "Juan Pérez: lo llevaron al hospital", Alert.last.title
    assert_no_match(/fractura/, Alert.last.body, "the clinical detail stays in the chart")
  end

  test "a discharge needs how the joven left, and the reason 'otro' needs what happened" do
    visit = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "otro")
    assert_not visit.start
    assert_includes visit.errors[:reason_detail], "escribe qué pasó"

    visit = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "fiebre").tap(&:start)
    assert_not visit.discharge(by: @nurse, disposition: "")
    assert_includes visit.errors[:disposition], "elige cómo salió"
  end

  test "only jovenes go to the infirmary" do
    visit = InfirmaryVisit.admit_directly(@counselor, by: @nurse, reason: "fiebre")
    assert_not visit.start
  end

  test "notes can't change once written and flag a fever" do
    visit = InfirmaryVisit.admit_directly(@juan, by: @nurse, reason: "fiebre").tap(&:start)
    note = visit.notes.create!(author: @nurse, author_name: @nurse.full_name, temperature: "38.4", heart_rate: "96", oxygen: "")

    assert_equal [ [ "38.4 °C", true ], [ "FC 96", false ] ], note.vital_readings
    assert_raises(ActiveRecord::ReadOnlyRecord) { note.update!(body: "otra cosa") }
    assert_not visit.notes.build(author_name: "X").valid?, "an empty note says nothing"
  end

  private
    def person(name, rol, gender, **attrs)
      Participant.create!(first_name: name, last_name: "Prueba", age: 30, stake: "bello_horizonte", ward: "ducuali",
                          shirt_number: "m", gender: gender, rol: rol, **attrs)
    end
end
