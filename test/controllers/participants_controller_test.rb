require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index shows the first 20 jóvenes and a lazy frame for the next page" do
    create_participants(25, prefix: "Joven")

    get participants_path

    assert_response :success
    assert_match(/Mostrando 1–20 de 26/, response.body)
    assert_includes response.body, "Joven20"
    refute_includes response.body, "Joven21"
    assert_select "turbo-frame#participants_page_2[loading=lazy]" do |frames|
      assert_includes frames.first["src"], "page=2"
    end
  end

  test "next-page frame request returns the remaining jóvenes without another sentinel" do
    create_participants(25, prefix: "Joven")

    get participants_path(page: 2), headers: { "Turbo-Frame" => "participants_page_2" }

    assert_response :success
    assert_select "turbo-frame#participants_page_2"
    assert_includes response.body, "Joven21"
    assert_includes response.body, "Juan"
    refute_includes response.body, "Joven01"
    assert_select "turbo-frame#participants_page_3", count: 0
  end

  test "next-page url keeps the active filters" do
    create_participants(21, prefix: "Villa", stake: "villa_flor")

    get participants_path(stake: "villa_flor")

    assert_select "turbo-frame#participants_page_2" do |frames|
      assert_includes frames.first["src"], "stake=villa_flor"
      assert_includes frames.first["src"], "page=2"
    end
  end

  test "a single page renders no next-page frame" do
    get participants_path

    assert_response :success
    assert_match(/Mostrando 1–1 de 1/, response.body)
    assert_select "turbo-frame[id^='participants_page_2']", count: 0
  end

  test "staff list paginates staff only" do
    create_participants(21, prefix: "Staff", rol: "consejero")

    get staff_participants_path

    assert_response :success
    assert_match(/Mostrando 1–20 de 22/, response.body)
    refute_includes response.body, "Juan Pérez"
  end

  test "update saves additional notes" do
    juan = participants(:juan)

    patch participant_path(juan), params: { participant: { additional_instructions: "Usa lentes de contacto" } }

    assert_redirected_to participant_path(juan, from: nil, return_to: dashboard_path)
    assert_equal "Usa lentes de contacto", juan.reload.additional_instructions
  end

  test "update saves the assigned company for the superadmin" do
    juan = participants(:juan)
    company = Company.create!(name: "Alfa 3")

    patch participant_path(juan), params: { participant: { company_id: company.id } }

    assert_equal company, juan.reload.company
  end

  test "update saves the assigned company for a director" do
    sign_out
    director = Participant.create!(first_name: "Roberto", last_name: "Sequeira", age: 45, stake: "bello_horizonte",
                                   ward: "la_rotonda", shirt_number: "l", gender: "H", rol: "director")
    sign_in_as(User.create!(email_address: "director@fsy.com", password: "Director1!", participant: director))
    juan = participants(:juan)
    company = Company.create!(name: "Beta 1")

    patch participant_path(juan), params: { participant: { company_id: company.id } }

    assert_equal company, juan.reload.company
  end

  private

  def create_participants(count, prefix:, **attrs)
    count.times do |i|
      Participant.create!({
        first_name: format("%s%02d", prefix, i + 1), last_name: "Prueba", age: 16,
        stake: "bello_horizonte", ward: "la_rotonda", shirt_number: "m", gender: "M", rol: "joven"
      }.merge(attrs))
    end
  end
end
