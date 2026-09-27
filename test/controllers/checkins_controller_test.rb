require "test_helper"

class CheckinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @company = Company.create!(number: 3)
    @joven = participants(:juan)
    @joven.update!(company: @company, room: "204", allergies: "Maní")
  end

  test "the screen shows how many are still missing" do
    get checkins_path

    assert_response :success
    assert_select "[data-arrived]", text: "0"
    assert_includes response.body, "de 1 jóvenes registrados"
  end

  test "the roster is what lets the device work without signal" do
    get checkins_roster_path, headers: { "Accept" => "application/json" }

    assert_response :success
    person = response.parsed_body["people"].first
    assert_equal @joven.full_name, person["name"]
    assert_equal @joven.stake.titleize, person["stake"]
    assert_equal Participant::GENDER_LABELS[@joven.gender], person["gender"]
    assert_equal participant_path(@joven), person["url"]
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
end
