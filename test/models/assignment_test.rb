require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @first_day = Rails.configuration.x.event_start_on
    @activity = Activity.create!(title: "Servicio comunitario", category: :servicio, location: "La Rotonda",
                                 date: (@first_day + 1).to_s, start_time: "10:00", end_time: "12:30")
  end

  test "an agenda assignment takes its title, schedule and place from the activity" do
    assignment = create_assignment(activity: @activity)

    assert assignment.from_agenda?
    assert_equal "Servicio comunitario", assignment.display_title
    assert_equal "Martes 12 de enero · 10:00 – 12:30", assignment.when_label
    assert_equal "La Rotonda", assignment.place
  end

  test "an assignment outside the agenda needs its own title" do
    assert_not build_assignment.valid?, "without an activity the title is required"
    assert build_assignment(title: "Primera oración").valid?
  end

  test "an assignment outside the agenda keeps its own schedule and place" do
    assignment = create_assignment(title: "Primera oración", starts_at: Time.zone.parse("#{@first_day} 06:30"),
                                   location: "Auditorio")

    assert_not assignment.from_agenda?
    assert_equal "Lunes 11 de enero · 06:30", assignment.when_label
    assert_equal "Auditorio", assignment.place
  end

  test "lists agenda and loose assignments in one timeline, undated last" do
    late = create_assignment(activity: @activity)
    early = create_assignment(title: "Oración", starts_at: Time.zone.parse("#{@first_day} 06:30"))
    undated = create_assignment(title: "Pendiente por agendar")

    assert_equal [ early, late, undated ], participants(:juan).assignments.chronological.to_a
  end

  private
    def build_assignment(**attributes)
      participants(:juan).assignments.new({ assigned_by_name: "Marta Jiménez" }.merge(attributes))
    end

    def create_assignment(**attributes)
      build_assignment(**attributes).tap(&:save!)
    end
end
