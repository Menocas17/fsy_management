require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  setup do
    @first_day = Rails.configuration.x.event_start_on
    @day = @first_day + 1
  end

  test "builds its schedule from the date and the two times" do
    activity = build_activity(date: @day.to_s, start_time: "10:00", end_time: "12:30")

    assert activity.save
    assert_equal Time.zone.parse("#{@day} 10:00"), activity.starts_at
    assert_equal 150, activity.duration_minutes
    assert_equal "10:00 – 12:30", activity.time_range
  end

  test "refuses an end time that is not after the start" do
    assert_not build_activity(start_time: "10:00", end_time: "10:00").valid?
    assert_not build_activity(start_time: "10:00", end_time: "09:00").valid?
  end

  test "refuses a day outside the event" do
    assert_not build_activity(date: (@first_day - 1).to_s).valid?
    assert_not build_activity(date: (Rails.configuration.x.event_end_on + 1).to_s).valid?
    assert build_activity(date: @first_day.to_s).valid?
  end

  test "role activities need at least one role" do
    assert_not build_activity(audience: :por_roles, target_roles: []).valid?
    assert build_activity(audience: :por_roles, target_roles: %w[logistica]).valid?
  end

  test "finds the activities of a day and of the whole event" do
    first = create_activity(date: @first_day.to_s)
    second = create_activity(date: @day.to_s)

    assert_equal [ first ], Activity.for_day(@first_day).to_a
    assert_equal [ first, second ], Activity.between(@first_day, Rails.configuration.x.event_end_on).to_a
  end

  test "each role reads its own note and managers read them all" do
    activity = create_activity(logistics_notes: "30 galones de pintura", counselors_notes: "Pasar lista",
                               youth_notes: "Llevar gorra")

    assert_equal [ "Logística" ], labels_for(activity, "logistica")
    assert_equal [ "Consejeros y auxiliares" ], labels_for(activity, "consejero")
    assert_equal [ "Jóvenes" ], labels_for(activity, "joven")
    assert_equal [ "Logística", "Consejeros y auxiliares", "Jóvenes" ], labels_for(activity, "coordinador")
    assert_equal 3, activity.notes_for(nil).size, "a superadmin reads every note"
  end

  private
    def build_activity(**attributes)
      Activity.new({ title: "Servicio comunitario", date: @day.to_s, start_time: "10:00", end_time: "12:30" }.merge(attributes))
    end

    def create_activity(**attributes)
      build_activity(**attributes).tap(&:save!)
    end

    def labels_for(activity, rol)
      activity.notes_for(Participant.new(rol: rol)).map { |note| note[:label] }
    end
end
