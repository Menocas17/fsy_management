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

  test "filters jóvenes by company number without mixing up similar numbers" do
    participants(:juan).update!(company: Company.create!(number: 1))
    Participant.create!(first_name: "Ana", last_name: "Diez", age: 15, stake: "villa_flor", shirt_number: "s",
                        gender: "M", rol: "joven", company: Company.create!(number: 10))

    get participants_path(company: "1")

    assert_includes response.body, "Juan Pérez"
    refute_includes response.body, "Ana Diez"
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

  test "edit renders every section of the redesigned form" do
    get edit_participant_path(participants(:juan))

    assert_response :success
    assert_select "form#participant-form"
    [ "Esencial", "Información general", "Asignaciones", "Contacto", "Médico", "Notas" ].each do |title|
      assert_select "h2", text: title
    end
    assert_select "button[type=submit][form='participant-form']", text: /Actualizar/
    assert_select "input[type=file][name='participant[avatar]'][data-avatar-preview-target=input]"
  end

  test "edit counts the assignments and sends you to the profile to change them" do
    juan = participants(:juan)
    juan.assignments.create!(title: "Primera oración", assigned_by_name: "Marta Jiménez")

    get edit_participant_path(juan)

    assert_select "a[href='#{participant_path(juan, anchor: "asignaciones")}']", text: /Ver asignaciones en el perfil/
    assert_includes response.body, "1 asignación registrada"
    assert_select "form#participant-form input[name^='assignment']", 0
  end

  test "edit offers delete to admins, and password reset only when coming from Mi perfil" do
    juan = participants(:juan)

    get edit_participant_path(juan)
    assert_select "button", text: /Borrar participante/
    assert_select "form[action='#{send_password_reset_participant_path(juan)}']", count: 0

    get edit_participant_path(juan, from: "myprofile")
    assert_select "form[action='#{send_password_reset_participant_path(juan)}']"
  end

  test "cancel and back links ignore unsafe return_to values" do
    juan = participants(:juan)

    [ "javascript:alert(1)", "//evil.example", "/\\evil.example" ].each do |unsafe|
      get edit_participant_path(juan, return_to: unsafe)
      assert_select "a", text: "Cancelar" do |links|
        assert_equal dashboard_path, links.first["href"], "#{unsafe} should fall back to the dashboard"
      end
    end

    get edit_participant_path(juan, return_to: "/participants?page=2")
    assert_select "a", text: "Cancelar" do |links|
      assert_equal "/participants?page=2", links.first["href"]
    end
  end

  test "new renders the create action without destructive options" do
    get new_participant_path

    assert_response :success
    assert_select "button[form='participant-form']", text: /Crear Registro/
    assert_select "button", text: /Borrar participante/, count: 0
  end

  test "profile shows assignment data under Información general and an honest empty Asignaciones state" do
    juan = participants(:juan)
    juan.update!(company: Company.create!(name: "Alfa 3"), room: "204",
                 m_person_in_charge: "Ana Ruiz", h_person_in_charge: "Pedro González")

    get participant_path(juan)

    assert_response :success
    assert_select "h2", text: "Información general"
    assert_includes response.body, "Alfa 3"
    assert_includes response.body, "Ana Ruiz · Pedro González"
    assert_select "[data-empty-state='asignaciones']", text: /Sin asignaciones todavía/
    refute_includes response.body, "Primera oración"
  end

  test "Mi perfil shows the signed-in participant, their QR and the way back home" do
    sign_out
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get myprofile_participants_path

    assert_response :success
    assert_select "h1", text: "María García"
    assert_select "[data-page-back] a[href='#{dashboard_path}']", text: /Inicio/
    assert_select "[data-profile-qr]", text: /Código QR/
    assert_select "a[href*='from=myprofile']", text: /Editar/
  end

  test "Mi perfil explains when the account has no linked participant" do
    get myprofile_participants_path

    assert_response :success
    assert_includes response.body, "no tiene un perfil de participante"
  end

  test "the kitchen filter narrows the list and says so" do
    participants(:juan).update!(allergies: "Maní")
    Participant.create!(first_name: "Sin", last_name: "Alergias", age: 15, stake: "las_americas",
                        shirt_number: "m", gender: "M", rol: :joven, allergies: "Ninguna")

    get participants_path(care: "allergies")

    assert_response :success
    assert_select "[data-active-filters] [data-active-filter='care']", text: /Con alergias/
    assert_select "tbody tr", 1
    assert_includes response.body, "Juan"
    refute_includes response.body, "Sin Alergias"
  end

  test "each active filter can be dropped on its own, keeping the rest" do
    get participants_path(care: "allergies", gender: "M", query: "jua")

    assert_select "[data-active-filter='care'][href*='gender=M']"
    assert_select "[data-active-filter='care'][href*='care=']", 0, "el enlace quita justo ese filtro"
    assert_select "[data-active-filter='gender'][href*='care=allergies']"
  end

  test "with no filters there is no filter bar to clear" do
    get participants_path

    assert_select "[data-active-filters]", 0
  end

  test "searching shows the count but no chip: the text is already in the box" do
    get participants_path(query: "jua")

    assert_select "[data-active-filters]", 1
    assert_select "[data-active-filter='query']", 0
    assert_select "[data-active-filters]", text: /resultado/
  end

  test "the filter bar works on the staff list too, and lives inside the table frame" do
    get staff_participants_path(rol: "consejero", stake: "las_americas")

    assert_response :success
    assert_select "turbo-frame#participants_table [data-active-filters]", 1, "debe redibujarse al filtrar"
    assert_select "[data-active-filter='rol']", text: /Consejero/
    assert_select "[data-active-filter='stake'][href*='rol=consejero']"
    assert_select "a[data-clear-filters][href='#{staff_participants_path}']"
  end

  test "removing a filter navigates the whole page, so the dropdowns follow" do
    get participants_path(gender: "M")

    assert_select "[data-active-filter='gender'][data-turbo-frame='_top']", 1
    assert_select "a[data-clear-filters][data-turbo-frame='_top']", 1
  end

  test "the way back ignores unsafe return_to values" do
    get participant_path(participants(:juan), return_to: "javascript:alert(1)")

    assert_select "[data-page-back] a", text: /Jóvenes/ do |links|
      assert_equal participants_path, links.first["href"]
    end
  end

  test "the profile carries a QR that opens the very same ficha" do
    juan = participants(:juan)

    get participant_path(juan)

    assert_select "[data-profile-qr]", 1
    assert_select "dialog[data-dialog-name='qr'] svg[role='img']", 1
    assert_select "dialog[data-dialog-name='qr']", html: /#{Regexp.escape(juan.full_name)}/
  end

  test "update records the edited fields in the history" do
    juan = participants(:juan)
    company = Company.create!(name: "Alfa 3")

    patch participant_path(juan), params: { participant: { room: "204", company_id: company.id } }

    log = AuditLog.recent.first
    assert log.asignaciones?
    assert_equal "Actualizó cuarto y compañía de Juan Pérez", log.summary
  end

  test "update without changes does not add history noise" do
    juan = participants(:juan)

    assert_no_difference -> { AuditLog.count } do
      patch participant_path(juan), params: { participant: { room: juan.room } }
    end
  end

  test "destroy records the deleted participant by name" do
    juan = participants(:juan)

    delete participant_path(juan)

    assert_equal "Eliminó el registro de Juan Pérez", AuditLog.recent.first.summary
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
