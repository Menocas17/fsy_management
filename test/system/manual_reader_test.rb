require "application_system_test_case"

# El lector de manuales dibuja el PDF de verdad con PDF.js: páginas, ir a otra y recordar dónde se iba.
class ManualReaderTest < ApplicationSystemTestCase
  setup do
    pdf = Prawn::Document.new
    3.times do |index|
      pdf.start_new_page unless index.zero?
      pdf.text "Hoja de prueba #{index + 1}", size: 24
    end
    Manual.for(:lideres).tap do |manual|
      manual.file.attach(io: StringIO.new(pdf.render), filename: "manual-lideres.pdf", content_type: "application/pdf")
      manual.save!
    end
  end

  test "the leaders' manual opens inside the app, turns pages and remembers where one was" do
    sign_in_as(users(:one))
    visit manuals_path
    find("[data-manual-link='lideres']").click

    assert_selector "[data-manual-reader='lideres'] [data-page='1'] canvas"
    assert_selector "[data-pdf-reader-target='total']", text: "3"

    find("[data-pdf-reader-target='next']", match: :first, visible: true).click
    assert_selector "[data-pdf-reader-target='current']", text: "2"
    assert_selector "[data-page='2'] canvas"

    visit manuals_path
    assert_selector "[data-manual-link='lideres'] [data-manual-progress-target='action']", text: "Seguir leyendo"
    find("[data-manual-link='lideres']").click
    assert_selector "[data-pdf-reader-target='current']", text: "2"
  end

  test "uploading a PDF shows its progress and then the manual is there" do
    sign_in_as(users(:one))
    visit manuals_path

    within "[data-manual='joven']" do
      attach_file "PDF del manual del joven", file_fixture("manual.pdf"), make_visible: true
    end
    assert_text "Manual del joven subido."
    assert_selector "[data-manual-link='joven']"
    assert Manual.for(:joven).available?
  end
end
