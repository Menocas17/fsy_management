require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "creating an activity announces it to everyone and records it" do
    assert_difference [ -> { Activity.count }, -> { Alert.count } ], 1 do
      post activities_path, params: { activity: activity_params }
    end

    activity = Activity.chronological.first
    alert = Alert.recent.first
    assert_redirected_to agenda_path(date: activity.day, activity_id: activity.id)
    assert_equal "Nueva actividad: Servicio comunitario", alert.title
    assert alert.source_agenda?
    assert alert.audience_todos?
    assert_equal activity, alert.activity
    assert_equal "Agregó «Servicio comunitario» a la agenda", AuditLog.agenda.recent.first.summary
    assert_equal "Envió la alerta «Nueva actividad: Servicio comunitario» a todos los participantes",
                 AuditLog.alertas.recent.first.summary, "the automatic alert shows up in Historial too"
  end

  test "a change announces what changed, and no change announces nothing" do
    activity = create_activity

    assert_difference -> { Alert.count }, 1 do
      patch activity_path(activity), params: { activity: activity_params(start_time: "11:00", location: "Parque central") }
    end

    alert = Alert.recent.first
    assert_equal "Cambio en la agenda: Servicio comunitario", alert.title
    assert_includes alert.body, "hora de inicio"
    assert_includes alert.body, "lugar"
    assert alert.priority_importante?

    assert_no_difference -> { Alert.count } do
      patch activity_path(activity), params: { activity: activity_params(start_time: "11:00", location: "Parque central") }
    end
  end

  test "a role activity only alerts those roles" do
    post activities_path, params: { activity: activity_params(audience: "por_roles", target_roles: [ "logistica" ]) }

    alert = Alert.recent.first
    assert alert.audience_por_roles?
    assert_equal [ "logistica" ], alert.target_roles
    assert_equal "Logística", alert.audience_label
  end

  test "deleting an activity cancels it and keeps the alert" do
    activity = create_activity

    assert_difference -> { Alert.count }, 1 do
      assert_difference -> { Activity.count }, -1 do
        delete activity_path(activity)
      end
    end

    assert_equal "Actividad cancelada: Servicio comunitario", Alert.recent.first.title
  end

  test "the form searches the staff and lists who is already responsible" do
    activity = create_activity
    activity.responsibles << participants(:maria)

    get edit_activity_path(activity)

    assert_response :success
    assert_select "input#responsible-search[data-participant-picker-target='query']"
    assert_select "[data-participant-picker-target='option'][data-id='#{participants(:maria).id}']"
    picked = "[data-participant-picker-target='selected'] [data-picked]"
    assert_select "#{picked}[data-id='#{participants(:maria).id}']", text: /María García/
    assert_select "#{picked} button[aria-label='Quitar a María García']"

    get new_activity_path
    assert_response :success
    assert_select picked, 0, "the chip inside the <template> doesn't count as a selection"
    assert_select "[data-participant-picker-target='empty']", text: /Nadie seleccionado/
  end

  test "removing every responsible leaves the activity without any" do
    activity = create_activity
    activity.responsibles << participants(:maria)

    patch activity_path(activity), params: { activity: activity_params(responsible_ids: [ "" ]) }

    assert_empty activity.reload.responsibles
  end

  test "counselors can't edit the agenda" do
    activity = create_activity
    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get new_activity_path
    assert_redirected_to agenda_path

    assert_no_difference -> { Activity.count } do
      delete activity_path(activity)
    end
  end

  private
    def activity_params(**overrides)
      { title: "Servicio comunitario", category: "servicio", date: (Rails.configuration.x.event_start_on + 1).to_s,
        start_time: "10:00", end_time: "12:30", location: "La Rotonda", audience: "todos" }.merge(overrides)
    end

    def create_activity
      Activity.create!(activity_params.except(:audience).merge(audience: :todos))
    end
end
