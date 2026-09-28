require "test_helper"

class ParticipantImporterTest < ActiveSupport::TestCase
  FIXTURE = Rails.root.join("test/fixtures/files/participantes.xlsx").to_s

  setup { @company = Company.create!(number: 3) }

  test "reads the spreadsheet and creates the participants it can" do
    import = nil

    assert_difference -> { Participant.count }, 3 do
      import = ParticipantImporter.new(FIXTURE).call
    end

    assert_nil import.fatal
    assert_equal 3, import.imported_count
  end

  test "maps the Spanish headers onto enums, company and the jsonb fields" do
    ParticipantImporter.new(FIXTURE).call
    ana = Participant.find_by(first_name: "Ana", last_name: "Ruiz")

    assert_equal 15, ana.age
    assert_equal "M", ana.gender
    assert_equal "las_americas", ana.stake
    assert_equal "ciudad_jardin", ana.ward
    assert_equal "s", ana.shirt_number
    assert_equal "joven", ana.rol, "sin columna de rol, entra como joven"
    assert_equal "101", ana.room
    assert_equal @company, ana.company
    assert_equal "8888-1111", ana.phone_number
    assert_equal "Maní", ana.allergies
  end

  test "a company number that does not exist leaves the ficha without company" do
    ParticipantImporter.new(FIXTURE).call

    assert_nil Participant.find_by(first_name: "Sofía").company
  end

  test "skips invalid rows with their reason and ignores empty ones" do
    import = ParticipantImporter.new(FIXTURE).call

    assert_equal 1, import.skipped_count, "la fila vacía no cuenta como omitida"
    skipped = import.skipped.first
    assert_equal 6, skipped.number
    assert_equal "Pedro SinEdad", skipped.name
    assert_match(/Edad/i, skipped.reason)
  end

  test "running it twice does not duplicate anybody" do
    ParticipantImporter.new(FIXTURE).call

    assert_no_difference -> { Participant.count } do
      second = ParticipantImporter.new(FIXTURE).call
      assert_equal 0, second.imported_count
      assert(second.skipped.all? { |row| row.reason.include?("duplicado") || row.reason.match?(/Edad/i) })
    end
  end

  test "an unreadable file comes back as a message, not an exception" do
    import = ParticipantImporter.new(Rails.root.join("README.md").to_s).call

    assert import.fatal.present?
    assert_equal 0, import.imported_count
  end

  test "a Nicaraguan cédula is kept whole, and the same cédula written differently is the same person" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol,Cédula",
                          "Luis,Mena,30,H,Villa Flor,L,Consejero,001-010190-0001A",
                          "Otro,Nombre,31,H,Villa Flor,M,Auxiliar,0010101900001a" ]

    assert_equal 1, import.imported_count
    assert_equal "0010101900001A", Participant.find_by(first_name: "Luis").identity_document
    assert_equal "001-010190-0001A", Participant.find_by(first_name: "Luis").formatted_identity_document
    assert_equal [ "duplicado: ya existe esta persona" ], import.skipped.map(&:reason)
    assert_equal Participant.find_by(first_name: "Luis"), import.skipped.first.match
  end

  test "two people with the same name are not merged unless age and stake match too" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla",
                          "María,López,15,M,Villa Flor,S",
                          "María,López,17,M,Las Américas,M",
                          "María,López,15,M,Villa Flor,S" ]

    assert_equal 2, import.imported_count
    assert_equal [ 4 ], import.skipped.map(&:number), "only the true repeat is skipped"
    assert_match(/mismo nombre/, import.warnings.first.reason)
  end

  test "same email or phone as someone else goes in, with a warning to check" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Correo,Teléfono",
                          "Ana,Uno,15,M,Villa Flor,S,familia@correo.com,8888-1111",
                          "Beto,Dos,16,H,Villa Flor,M,FAMILIA@correo.com,+505 8888 1111" ]

    assert_equal 2, import.imported_count
    assert_equal [ "mismo correo que otra persona · mismo teléfono que otra persona" ], import.warnings.map(&:reason)
  end

  test "staff can be imported with any role, and more than two coordinators is fine" do
    rows = (1..3).map { |i| "Coord#{i},Apellido,40,H,Villa Flor,L,Coordinador" }
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol" ] + rows + [ "Ana,Consejera,25,M,Villa Flor,M,consejero" ]

    assert_equal 4, import.imported_count
    assert_equal 3, Participant.coordinador.count
    assert Participant.find_by(first_name: "Ana").consejero?
  end

  test "a staff member's company column is not applied, and says so" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol,Compañía",
                          "Ana,Consejera,25,M,Villa Flor,M,Consejero,3" ]

    assert_nil Participant.find_by(first_name: "Ana").company
    assert_match(/no se asigna al staff/, import.warnings.first.reason)
  end

  test "F means mujer, and an age in words is refused as not a number" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla",
                          "Sara,Uno,15,F,Villa Flor,S",
                          "Luis,Dos,quince,H,Villa Flor,M" ]

    assert_equal "M", Participant.find_by(first_name: "Sara").gender
    assert_equal [ "Edad debe ser un número" ], import.skipped.map(&:reason)
  end

  private
    def import_csv(lines)
      Tempfile.create([ "carga", ".csv" ]) do |file|
        file.write(lines.join("\n"))
        file.flush
        ParticipantImporter.new(file.path).call
      end
    end
end
