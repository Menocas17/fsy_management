require "test_helper"

class ParticipantImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    Company.create!(number: 3)
  end

  test "the form explains which columns it reads" do
    get new_participant_import_path

    assert_response :success
    assert_select "input[type=file][name=file]"
    assert_includes response.body, "Compañía"
  end

  test "uploading the spreadsheet creates the participants and reports the rest" do
    assert_difference -> { Participant.count }, 3 do
      post participant_import_path, params: { file: spreadsheet }
    end

    assert_response :success
    assert_select "[data-import='imported']", text: "3"
    assert_select "[data-import='skipped']", text: "1"
    assert_includes response.body, "Pedro SinEdad"
  end

  test "the upload is written to the history" do
    assert_difference -> { AuditLog.count }, 1 do
      post participant_import_path, params: { file: spreadsheet }
    end

    assert_match(/Cargó 3 participantes/, AuditLog.order(:created_at).last.summary)
  end

  test "sending no file asks for one instead of failing" do
    post participant_import_path

    assert_redirected_to new_participant_import_path
    assert_equal "Elegí un archivo para cargar.", flash[:alert]
  end

  test "a file it cannot read explains itself" do
    post participant_import_path, params: { file: fixture_file_upload("participantes.xlsx", "text/plain").tap { |f| f.define_singleton_method(:original_filename) { "notas.txt" } } }

    assert_response :unprocessable_entity
    assert_select "#flash-messages", /No se pudo leer el archivo/
  end

  test "only full access and registradores may import" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get new_participant_import_path
    assert_redirected_to dashboard_path

    assert_no_difference -> { Participant.count } do
      post participant_import_path, params: { file: spreadsheet }
    end
  end

  private
    def spreadsheet
      fixture_file_upload("participantes.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    end
end
