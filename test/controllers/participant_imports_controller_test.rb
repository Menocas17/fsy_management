require "test_helper"

class ParticipantImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    Company.create!(number: 3)
  end

  test "the upload page explains the columns and lists earlier imports" do
    ParticipantImport.create!(filename: "anterior.xlsx", uploaded_by_name: "Admin")

    get new_participant_import_path

    assert_response :success
    assert_select "input[type=file][name=file]"
    assert_includes response.body, "Compañía auxiliar"
    assert_select "[data-imports] a", text: /anterior.xlsx/
  end

  test "uploading goes to a saved report: who went in and who waits" do
    assert_difference -> { Participant.count }, 2 do
      post participant_imports_path, params: { file: spreadsheet }
    end
    import = ParticipantImport.last
    assert_redirected_to participant_import_path(import)

    follow_redirect!
    assert_select "[data-import-count='entraron']", text: "2"
    assert_select "[data-import-count='por-resolver']", text: "2"
    assert_select "[data-pending-row='6']", text: /Pedro SinEdad/
  end

  test "the report is still there later, and a row can be corrected and approved from it" do
    post participant_imports_path, params: { file: spreadsheet }
    import = ParticipantImport.last
    pedro = import.rows.pending.find { |row| row.values["first_name"] == "Pedro" }

    get participant_import_path(import)
    assert_select "[data-pending-row='6'] form[action='#{approve_participant_import_row_path(import, pedro)}']", 0, "blocked: no approve button"

    get edit_participant_import_row_path(import, pedro)
    assert_response :success
    patch participant_import_row_path(import, pedro), params: { row: { age: "16" } }
    assert_redirected_to participant_import_path(import, anchor: "fila-6")

    assert_difference -> { Participant.count }, 1 do
      patch approve_participant_import_row_path(import, pedro)
    end
    assert pedro.reload.approved?

    get participant_import_path(import, vista: "entraron")
    assert_select "[data-rows='entraron'] a", text: /Pedro SinEdad/
  end

  test "a row can be discarded and stays in the report as discarded" do
    post participant_imports_path, params: { file: spreadsheet }
    import = ParticipantImport.last
    sofia = import.rows.pending.find { |row| row.values["first_name"] == "Sofía" }

    assert_no_difference -> { Participant.count } do
      patch discard_participant_import_row_path(import, sofia)
    end
    get participant_import_path(import, vista: "descartadas")
    assert_select "[data-rows='descartadas']", text: /Sofía/
  end

  test "the upload is written to the history" do
    assert_difference -> { AuditLog.count }, 1 do
      post participant_imports_path, params: { file: spreadsheet }
    end
    assert_match(/2 entraron, 2 por resolver/, AuditLog.last.summary)
  end

  test "sending no file asks for one instead of failing" do
    post participant_imports_path

    assert_redirected_to new_participant_import_path
    assert_equal "Elige un archivo para cargar.", flash[:alert]
  end

  test "a file it cannot read explains itself" do
    post participant_imports_path, params: { file: fixture_file_upload("factura.png", "image/png") }

    assert_response :unprocessable_entity
    assert_select "#flash-messages", /No se pudo leer el archivo/
  end

  test "only full access and the Registro area may import" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get new_participant_import_path
    assert_redirected_to dashboard_path

    assert_no_difference -> { Participant.count } do
      post participant_imports_path, params: { file: spreadsheet }
    end
  end

  test "with full access the page has three tabs: companies, counselors and jóvenes" do
    get new_participant_import_path(tipo: "companias")

    assert_select "[data-import-tab]", 3
    assert_select "[data-import-form='companias'] form[action='#{company_imports_path}']"
  end

  test "companies are uploaded from their tab and come back with a summary" do
    post company_imports_path, params: { file: csv_upload("Número,Compañía auxiliar\n7,Alfa\n8,Alfa\n") }

    assert_redirected_to new_participant_import_path(tipo: "companias")
    assert_equal "2 compañías nuevas.", flash[:notice]
    assert_equal [ 7, 8 ], AuxiliarCompany.find_by!(name: "Auxiliar Alfa").companies.order(:number).pluck(:number)
  end

  test "counselors uploaded from their tab sit in their company at once" do
    file = csv_upload("Nombre,Apellido,Edad,Sexo,Estaca,Talla de camiseta,Compañía\nLuis,Uno,25,Masculino,Villa Flor,M,3\n")

    post participant_imports_path, params: { file: file, tipo: "consejeros" }

    luis = Participant.find_by!(first_name: "Luis")
    assert luis.consejero?
    assert_equal [ 3 ], luis.companies.pluck(:number)
  end

  test "registration (logística) only sees the jóvenes tab and can't upload companies" do
    registrar = Participant.create!(first_name: "Rita", last_name: "Registro", age: 30, stake: "villa_flor", shirt_number: "m",
                                    gender: "M", rol: "logistica", logistics_area: LogisticsArea.create!(name: "Registro", checkin: true))
    sign_in_as(User.create!(email_address: "rita@fsy.com", password: "Prueba123!", participant: registrar))

    get new_participant_import_path(tipo: "companias")
    assert_select "[data-import-tab]", 0
    assert_select "[data-import-form='jovenes']"

    post company_imports_path, params: { file: csv_upload("Número\n9\n") }
    assert_nil Company.find_by(number: 9)
  end

  private
    def spreadsheet
      fixture_file_upload("participantes.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    end

    def csv_upload(content)
      file = Tempfile.new([ "carga", ".csv" ])
      file.write(content)
      file.rewind
      Rack::Test::UploadedFile.new(file.path, "text/csv", original_filename: "carga.csv")
    end
end
