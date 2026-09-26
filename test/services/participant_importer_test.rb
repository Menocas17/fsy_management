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
      assert(second.skipped.all? { |row| row.reason.include?("ya estaba registrado") || row.reason.match?(/Edad/i) })
    end
  end

  test "an unreadable file comes back as a message, not an exception" do
    import = ParticipantImporter.new(Rails.root.join("README.md").to_s).call

    assert import.fatal.present?
    assert_equal 0, import.imported_count
  end
end
