require "test_helper"

class CheckinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @company = Company.create!(number: 3)
    @joven = participants(:juan)
    @joven.update!(company: @company, room: "204", allergies: "Maní")
    # La llegada solo se escanea el día del evento; estas pruebas la abren a mano, como haría el admin.
    AppSetting[ScanWindow::ARRIVAL_KEY] = "open"
  end

  test "the screen shows how many are still missing" do
    get checkins_path

    assert_response :success
    assert_select "[data-arrived]", text: "0"
    assert_includes response.body, "de 1 jóvenes registrados"
  end

  test "the scanner keeps a spot below the camera for the last scan" do
    get checkins_path

    assert_select "[data-checkin-scanner-target='card'][data-action*='dismissCard']"
    assert_select "[data-last-scan][hidden]"
  end

  test "the roster is what lets the device work without signal" do
    get checkins_roster_path, headers: { "Accept" => "application/json" }

    assert_response :success
    person = response.parsed_body["people"].first
    assert_equal @joven.full_name, person["name"]
    assert_equal "Compañía 3", person["company"]
    assert_equal @joven.stake.titleize, person["stake"]
    assert_equal Participant::GENDER_LABELS[@joven.gender], person["gender"]
    assert_equal participant_path(@joven, from: "escaner", return_to: checkins_path), person["url"]
    assert_nil person["care"], "los datos médicos no viajan al padrón del dispositivo"
    refute person["arrived"]
  end

  test "a scan registers the arrival with who took it" do
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "abc" } ] }, as: :json

    assert_response :success
    assert_equal "registered", response.parsed_body["results"].first["status"]
    assert_equal 1, response.parsed_body["arrived"]
    assert @joven.reload.arrived?
    assert_equal "Administrador del sistema", Checkin.last.recorded_by_name
  end

  test "resending the queue after the signal comes back does not duplicate" do
    scan = { participant_id: @joven.id, client_token: "mismo-token" }

    assert_difference -> { Checkin.count }, 1 do
      2.times { post register_checkins_path, params: { checkins: [ scan ] }, as: :json }
    end

    assert_equal "already", response.parsed_body["results"].first["status"]
  end

  test "scanning the same person twice says they were already in" do
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "uno" } ] }, as: :json
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "dos" } ] }, as: :json

    assert_equal 1, Checkin.count
    assert_equal "already", response.parsed_body["results"].first["status"]
  end

  test "the arrival keeps the time of the scan, not of the sync" do
    scanned_at = 40.minutes.ago

    post register_checkins_path,
         params: { checkins: [ { participant_id: @joven.id, client_token: "tarde", recorded_at: scanned_at.iso8601 } ] },
         as: :json

    assert_in_delta scanned_at, Checkin.last.recorded_at, 1.second
  end

  test "a made-up code is reported instead of blowing up the batch" do
    post register_checkins_path,
         params: { checkins: [ { participant_id: SecureRandom.uuid, client_token: "raro" },
                               { participant_id: @joven.id, client_token: "bueno" } ] }, as: :json

    statuses = response.parsed_body["results"].map { |result| result["status"] }
    assert_equal [ "unknown", "registered" ], statuses
    assert_equal 1, Checkin.count
  end

  test "the registration committee can register" do
    area = LogisticsArea.create!(name: "Registro de prueba", checkin: true)
    member = Participant.create!(first_name: "Rosa", last_name: "Registro", age: 28, stake: "las_americas",
                                 shirt_number: "m", gender: "M", rol: :logistica, logistics_area: area)
    sign_in_as(User.create!(email_address: "rosa@fsy.com", password: "Registro1!", participant: member))

    get checkins_path
    assert_response :success

    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "x" } ] }, as: :json
    assert_equal member.full_name, Checkin.last.recorded_by_name
  end

  test "logistics outside that committee may look but not register" do
    area = LogisticsArea.create!(name: "Decoración de prueba")
    member = Participant.create!(first_name: "Luis", last_name: "Decora", age: 28, stake: "las_americas",
                                 shirt_number: "l", gender: "H", rol: :logistica, logistics_area: area)
    sign_in_as(User.create!(email_address: "luis@fsy.com", password: "Decora11!", participant: member))

    get checkins_path
    assert_redirected_to dashboard_path

    assert_no_difference -> { Checkin.count } do
      post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "y" } ] }, as: :json
    end
  end

  test "a consejero cannot register arrivals" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get checkins_path
    assert_redirected_to dashboard_path
  end

  test "outside its day the arrival is closed: no scanner, no roster, no registrations" do
    AppSetting[ScanWindow::ARRIVAL_KEY] = "auto"

    travel_to Rails.configuration.x.event_start_on - 10.days do
      sign_in_as(users(:one)) # la sesión creada «hoy» ya venció en la fecha simulada
      get checkins_path
      assert_select "[data-scan-closed-card]", text: /Se abre el/
      assert_select "[data-controller='checkin-scanner']", 0

      get checkins_roster_path, headers: { "Accept" => "application/json" }
      assert_response :forbidden

      assert_no_difference -> { Checkin.count } do
        post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "x1" } ] }, as: :json
      end
      assert_equal "closed", response.parsed_body["results"].first["status"]
    end
  end

  test "on its day the arrival opens by itself, and what was scanned that day syncs the day after" do
    AppSetting[ScanWindow::ARRIVAL_KEY] = "auto"
    day = Rails.configuration.x.event_start_on

    travel_to day.in_time_zone.change(hour: 9) do
      sign_in_as(users(:one)) # la sesión creada «hoy» ya venció en la fecha simulada
      get checkins_path
      assert_select "[data-controller='checkin-scanner']", 1
    end

    travel_to (day + 1).in_time_zone.change(hour: 8) do
      sign_in_as(users(:one)) # la sesión creada «hoy» ya venció en la fecha simulada
      scanned_at = day.in_time_zone.change(hour: 18).iso8601
      assert_difference -> { Checkin.count }, 1 do
        post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "late", recorded_at: scanned_at } ] }, as: :json
      end
    end
  end

  test "a training that is not today is not offered for scanning" do
    AppSetting[ScanWindow::ARRIVAL_KEY] = "auto"
    december = Training.create!(name: "Diciembre", held_on: 2.months.from_now.to_date)
    today = Training.create!(name: "Hoy", held_on: Date.current)

    get checkins_path(training_id: today.id)
    assert_select "[data-scan-mode='training-#{today.id}']"
    assert_select "[data-scan-mode='training-#{december.id}']", 0

    get checkins_path(training_id: december.id)
    assert_select "[data-scan-closed-card]"
  end

  test "with the arrival closed, the scanner goes straight to the training open today" do
    AppSetting[ScanWindow::ARRIVAL_KEY] = "closed"
    today = Training.create!(name: "Hoy", held_on: Date.current)

    get checkins_path
    assert_redirected_to checkins_path(training_id: today.id)
  end

  test "the short badge code typed by hand registers too" do
    @joven.update_columns(code: "P-0421")

    assert_difference -> { Checkin.count }, 1 do
      post register_checkins_path, params: { checkins: [ { participant_id: "421", client_token: "by-code" } ] }, as: :json
    end

    get checkins_roster_path, headers: { "Accept" => "application/json" }
    assert_equal "P-0421", response.parsed_body["people"].first["code"]
  end

  test "the last scan can be voided with a reason: the person is back to not arrived, and it is in the history" do
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "scan-1" } ] }, as: :json

    assert_difference -> { AuditLog.registro.count }, 1 do
      post register_checkins_path, as: :json, params: { checkins: [
        { kind: "void", client_token: "void-1", target_token: "scan-1", participant_id: @joven.id,
          reason: "otra_persona", detail: "Llegó su hermano con el gafete" } ] }
    end

    assert_equal "voided", response.parsed_body["results"].first["status"]
    assert_equal 0, response.parsed_body["arrived"]
    assert_not @joven.reload.arrived?
    log = AuditLog.registro.sole
    assert_equal @joven.id, log.target_id
    assert_equal "Anuló la llegada de #{@joven.full_name} (No era la persona: Llegó su hermano con el gafete)", log.summary
  end

  test "a scan and its void taken without signal arrive together and cancel out" do
    post register_checkins_path, as: :json, params: { checkins: [
      { participant_id: @joven.id, client_token: "offline-scan" },
      { kind: "void", client_token: "offline-void", target_token: "offline-scan", participant_id: @joven.id, reason: "escaneo_incorrecto" } ] }

    assert_equal %w[registered voided], response.parsed_body["results"].map { |r| r["status"] }
    assert_equal 0, Checkin.count
    assert_match(/\(Escaneo incorrecto\)\z/, AuditLog.registro.sole.summary)
  end

  test "voiding a scan that found the person already in never removes the real arrival" do
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "real" } ] }, as: :json
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "impostor" } ] }, as: :json

    post register_checkins_path, as: :json, params: { checkins: [
      { kind: "void", client_token: "v", target_token: "impostor", participant_id: @joven.id, reason: "otra_persona" } ] }

    assert_equal "void_missing", response.parsed_body["results"].first["status"]
    assert @joven.reload.arrived?
  end

  test "a record from the recent list is voided by its id, and the list offers it" do
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "x" } ] }, as: :json
    checkin = Checkin.sole

    get checkins_path
    assert_select "[data-recent-record='#{checkin.id}'] button[data-action='checkin-scanner#askVoid'][data-record-id='#{checkin.id}']", text: "Anular"
    assert_select "dialog[data-void-dialog] [data-void-reason]", 3

    post register_checkins_path, as: :json, params: { checkins: [ { kind: "void", client_token: "v", record_id: checkin.id, participant_id: @joven.id, reason: "otro" } ] }
    assert_not @joven.reload.arrived?
  end

  test "a void needs a reason from the list" do
    post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "x" } ] }, as: :json

    post register_checkins_path, as: :json, params: { checkins: [ { kind: "void", client_token: "v", target_token: "x", reason: "porque si" } ] }

    assert_equal "invalid", response.parsed_body["results"].first["status"]
    assert @joven.reload.arrived?
  end

  test "voiding a training attendance only touches that training" do
    training = Training.create!(name: "Primeros auxilios", held_on: Date.current)
    staff = participants(:maria)
    Checkin.register(participant: @joven, recorded_by: nil, client_token: "llegada")

    post register_checkins_path(training_id: training.id), params: { checkins: [ { participant_id: staff.id, client_token: "t1" } ] }, as: :json
    post register_checkins_path(training_id: training.id), as: :json, params: { checkins: [
      { kind: "void", client_token: "v", target_token: "t1", participant_id: staff.id, reason: "escaneo_incorrecto" } ] }

    assert_equal 0, training.attendances.count
    assert_equal 1, Checkin.count, "the arrival is a different registry"
    assert_match(/Anuló la asistencia a Primeros auxilios/, AuditLog.registro.sole.summary)
  end

  test "registradores register and void too" do
    registrador = Participant.create!(first_name: "Rita", last_name: "Registro", age: 30, stake: "villa_flor",
                                      shirt_number: "m", gender: "M", rol: "registrador")
    sign_in_as(User.create!(email_address: "rita@fsy.com", password: "Registro1!", participant: registrador))

    get checkins_path
    assert_response :success
  end
end
