require "test_helper"

class CheckinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @company = Company.create!(number: 3)
    @joven = participants(:juan)
    @joven.update!(company: @company, room: "204", allergies: "Maní")
    # Sin nada activo el escáner está cerrado; estas pruebas activan la llegada, como haría el admin.
    ScanWindow.activate!(ScanWindow.arrival)
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

  test "with nothing active the scanner is closed: no scanner, no roster, no registrations" do
    ScanWindow.activate!(nil)

    get checkins_path
    assert_select "[data-scan-closed-card]", text: /No está activo/
    assert_select "[data-controller='checkin-scanner']", 0

    get checkins_roster_path, headers: { "Accept" => "application/json" }
    assert_response :forbidden

    assert_no_difference -> { Checkin.count } do
      post register_checkins_path, params: { checkins: [ { participant_id: @joven.id, client_token: "x1" } ] }, as: :json
    end
    assert_equal "closed", response.parsed_body["results"].first["status"]
  end

  test "what was scanned offline while the arrival was active syncs after switching to a training" do
    training = Training.create!(name: "Hoy", held_on: Date.current)
    ScanWindow.activate!(nil)
    travel_to(2.hours.ago) { ScanWindow.activate!(ScanWindow.arrival) }
    ScanWindow.activate!(ScanWindow.for(training))

    assert_difference -> { Checkin.count }, 1 do
      post register_checkins_path, as: :json, params: { checkins: [
        { participant_id: @joven.id, client_token: "late", recorded_at: 1.hour.ago.iso8601 },
        { participant_id: participants(:maria).id, client_token: "after" } ] }
    end
    assert_equal %w[registered closed], response.parsed_body["results"].map { |result| result["status"] }
  end

  test "only the active training is scanned, without a selector between registrations" do
    other = Training.create!(name: "Diciembre", held_on: 2.months.from_now.to_date)
    today = Training.create!(name: "Hoy", held_on: Date.current)
    ScanWindow.activate!(ScanWindow.for(today))

    get checkins_path
    assert_redirected_to checkins_path(training_id: today.id)

    get checkins_path(training_id: today.id)
    assert_select "[data-scan-current]", text: /Hoy/
    assert_select "[data-scan-modes]", 0
    assert_select "[data-controller='checkin-scanner']", 1

    get checkins_path(training_id: other.id)
    assert_select "[data-scan-closed-card]"
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
    ScanWindow.activate!(ScanWindow.for(training))
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
