require "test_helper"

class ParticipantImporterTest < ActiveSupport::TestCase
  FIXTURE = Rails.root.join("test/fixtures/files/participantes.xlsx").to_s

  setup { @company = Company.create!(number: 3) }

  test "clean rows go straight in; rows with a problem wait outside the base" do
    import = nil
    assert_difference -> { Participant.count }, 2 do
      import = ParticipantImporter.new(FIXTURE).call.import
    end

    assert_equal 2, import.count_of(:imported)
    assert_equal [ "Sofía", "Pedro" ], import.rows.pending.map { |row| row.values["first_name"] }
    assert_nil Participant.find_by(first_name: "Sofía"), "a row in wait is not in the base"
    assert_equal 4, import.rows.count, "the empty row is not stored"
  end

  test "maps the Spanish headers onto enums, company and the jsonb fields" do
    ParticipantImporter.new(FIXTURE).call
    ana = Participant.find_by(first_name: "Ana", last_name: "Ruiz")

    assert_equal [ 15, "M", "las_americas", "ciudad_jardin", "s", "joven", "101" ],
                 [ ana.age, ana.gender, ana.stake, ana.ward, ana.shirt_number, ana.rol, ana.room ]
    assert_equal @company, ana.company
    assert_equal "8888-1111", ana.phone_number
    assert_equal "Maní", ana.allergies
  end

  test "a row in wait says why, and which issues block approving it" do
    import = ParticipantImporter.new(FIXTURE).call.import
    sofia, pedro = import.rows.pending.to_a

    assert_equal [ "La compañía 99 no existe: quedaría sin compañía" ], sofia.issues.map { |i| i["text"] }
    refute sofia.blocking?, "a missing company can be approved knowingly"
    assert pedro.blocking?
    assert_match(/Edad/, pedro.issues.first["text"])
  end

  test "running it twice holds every row as a duplicate, pointing at the existing ficha" do
    ParticipantImporter.new(FIXTURE).call

    assert_no_difference -> { Participant.count } do
      second = ParticipantImporter.new(FIXTURE).call.import
      ana = second.rows.find { |row| row.values["first_name"] == "Ana" }
      assert ana.pending?
      assert_equal Participant.find_by(first_name: "Ana").id, ana.issues.first["match_id"]
    end
  end

  test "an unreadable file comes back as a message, not an exception" do
    importer = ParticipantImporter.new(Rails.root.join("README.md").to_s).call

    assert importer.fatal.present?
    assert_nil importer.import
  end

  test "a Nicaraguan cédula is kept whole, and the same cédula written differently is the same person" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol,Cédula",
                          "Luis,Mena,30,H,Villa Flor,L,Logística,001-010190-0001A",
                          "Otro,Nombre,31,H,Villa Flor,M,Logística,0010101900001a" ]

    luis = Participant.find_by(first_name: "Luis")
    assert_equal [ "0010101900001A", "001-010190-0001A" ], [ luis.identity_document, luis.formatted_identity_document ]
    assert_equal [ [ "Duplicado: esta persona ya existe", luis.id ] ], import.rows.pending.flat_map { |r| r.issues.map { |i| [ i["text"], i["match_id"] ] } }
  end

  test "two people with the same name are not merged unless age and stake match too" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla",
                          "María,López,15,M,Villa Flor,S",
                          "María,López,17,M,Las Américas,M",
                          "María,López,15,M,Villa Flor,S" ]

    texts = import.rows.pending.map { |row| row.issues.map { |i| i["text"] } }
    assert_equal [ [ "Mismo nombre que otra persona" ], [ "Duplicado: esta persona ya existe" ] ], texts
  end

  test "same email or phone as someone else waits for approval" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Correo,Teléfono",
                          "Ana,Uno,15,M,Villa Flor,S,familia@correo.com,8888-1111",
                          "Beto,Dos,16,H,Villa Flor,M,FAMILIA@correo.com,+505 8888 1111" ]

    beto = import.rows.pending.sole
    assert_equal [ "Mismo correo que otra persona", "Mismo teléfono que otra persona" ], beto.issues.map { |i| i["text"] }
    refute beto.blocking?
  end

  test "the leadership is one man and one woman per role: a third one waits, blocked" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol",
                          "Pedro,Director,55,H,Villa Flor,L,Director",
                          "Rosa,Directora,53,M,Villa Flor,M,Directora",
                          "Luis,Coord,45,H,Villa Flor,L,Coordinador",
                          "Ana,Coord,44,M,Villa Flor,M,Coordinadora",
                          "Beto,Coord,46,H,Villa Flor,L,Coordinador",
                          "Juan,Logística,42,H,Villa Flor,L,Director de logística" ]

    assert_equal [ 2, 2, 1 ], [ Participant.director.count, Participant.coordinador.count, Participant.director_logistica.count ]
    beto = import.rows.pending.sole
    assert beto.blocking?
    assert_match(/Ya hay coordinador hombre: Luis Coord/, beto.issues.first["text"])
    assert_equal Participant.find_by(first_name: "Luis").id, beto.issues.first["match_id"]
  end

  test "counselors are staffed one man and one woman per company; the rest wait" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol,Compañía",
                          "Luis,Uno,25,H,Villa Flor,M,Consejero,3",
                          "Ana,Dos,24,M,Villa Flor,S,Consejera,3",
                          "Beto,Tres,26,H,Villa Flor,L,Consejero,3",
                          "Sara,Cuatro,23,M,Villa Flor,S,Consejero,",
                          "Juan,Cinco,27,H,Villa Flor,M,Consejero,99" ]

    assert_equal %w[Luis Ana], @company.memberships.includes(:participant).map { |m| m.participant.first_name }
    issues = import.rows.pending.to_h { |row| [ row.values["first_name"], row.issues.first ] }
    assert_equal "Compañía 3 ya tiene consejero: Luis Uno", issues["Beto"]["text"]
    assert issues["Beto"]["blocking"]
    refute issues["Sara"]["blocking"], "without company it can be approved and staffed later"
    assert issues["Juan"]["blocking"]
  end

  test "auxiliaries are staffed on their auxiliary company by name, or through their company" do
    beta = AuxiliarCompany.create!(name: "Auxiliar Beta")
    @company.update!(auxiliar_company: beta)
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol,Compañía auxiliar,Compañía",
                          "Luis,Uno,30,H,Villa Flor,M,Auxiliar,beta,",
                          "Ana,Dos,31,M,Villa Flor,S,Auxiliar,,3",
                          "Beto,Tres,32,H,Villa Flor,L,Auxiliar,Auxiliar Beta,",
                          "Sara,Cuatro,33,M,Villa Flor,S,Auxiliar,Zeta," ]

    assert_equal %w[Ana Luis], beta.auxiliars.map(&:first_name).sort
    texts = import.rows.pending.map { |row| row.issues.first["text"] }
    assert_equal [ "Auxiliar Beta ya tiene auxiliar hombre: Luis Uno", "La compañía auxiliar «Zeta» no existe" ], texts
  end

  test "roles by their Spanish name and in feminine; an unknown one waits as joven" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla,Rol,Compañía",
                          "Ana,Uno,40,M,Villa Flor,M,Directora de logística,",
                          "Eva,Tres,25,M,Villa Flor,S,consejera,3",
                          "Juan,Cuatro,30,H,Villa Flor,M,Voluntario," ]

    assert_equal %w[director_logistica consejero], %w[Ana Eva].map { |name| Participant.find_by(first_name: name).rol }
    assert import.rows.pending.any? { |row| row.values["first_name"] == "Juan" && row.issues.first["text"].include?("«Voluntario» no existe") }
  end

  test "F means mujer, and an age in words blocks as not a number" do
    import = import_csv [ "Nombres,Apellidos,Edad,Sexo,Estaca,Talla",
                          "Sara,Uno,15,F,Villa Flor,S",
                          "Luis,Dos,quince,H,Villa Flor,M" ]

    assert_equal "M", Participant.find_by(first_name: "Sara").gender
    assert_equal [ "Edad debe ser un número" ], import.rows.pending.sole.issues.map { |i| i["text"] }
  end

  private
    def import_csv(lines)
      Tempfile.create([ "carga", ".csv" ]) do |file|
        file.write(lines.join("\n"))
        file.flush
        ParticipantImporter.new(file.path).call.import
      end
    end
end
