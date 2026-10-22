require "test_helper"

class ManualsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @joven = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: participants(:juan))
    @counselor = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    @director = Participant.create!(first_name: "Roberto", last_name: "Prueba", age: 45, gender: "H", rol: "director",
                                    stake: "bello_horizonte", ward: "la_rotonda", shirt_number: "l")
  end

  def upload(kind, file = "manual.pdf", type = "application/pdf")
    patch upload_manual_path(kind), params: { file: fixture_file_upload(file, type) }
  end

  test "the joven sees their manual and the Gospel Library links, never the leaders' manual" do
    Manual.for(:joven).tap { |manual| manual.file.attach(fixture_file_upload("manual.pdf", "application/pdf")) }.save!
    Manual.for(:lideres).tap { |manual| manual.file.attach(fixture_file_upload("manual.pdf", "application/pdf")) }.save!
    sign_in_as(@joven)

    get manuals_path
    assert_response :success
    assert_select "[data-manual='joven'] a[data-manual-link='joven'][href='#{read_manual_path(:joven)}']"
    assert_select "[data-manual='lideres']", false
    assert_select "[data-manual-library='predicad'][href^='https://www.churchofjesuschrist.org']"
    assert_select "[data-manual-library='fortaleza']"
    assert_select "[data-manual-library='musica']", false, "sin enlace guardado, la música no sale"
    assert_select "[data-manual-upload]", false
  end

  test "the staff sees both manuals and the links, and a missing one says so" do
    sign_in_as(@counselor)

    get manuals_path
    assert_select "[data-manual='lideres'] [data-manual-missing]", text: /Todavía no está disponible/
    assert_select "[data-manual='joven'] [data-manual-missing]"
    assert_select "[data-manual-library='predicad']"
    assert_select "[data-manual-upload]", false
    assert_select "a[href='#{links_manuals_path}']", false
  end

  test "full access uploads, replaces and removes a manual's PDF, and it stays in Historial" do
    sign_in_as(User.create!(email_address: "roberto@fsy.com", password: "Director1!", participant: @director))

    get manuals_path
    assert_select "form[data-manual-upload='lideres'] input[type='file'][accept='application/pdf']"

    assert_difference -> { AuditLog.where(category: :manuales).count }, 1 do
      upload(:lideres)
    end
    assert_redirected_to manuals_path
    assert Manual.for(:lideres).available?
    assert_equal "Roberto Prueba", Manual.for(:lideres).uploaded_by_name

    upload(:lideres)
    assert_match "Reemplazó", AuditLog.recent.first.summary

    delete remove_manual_path(:lideres)
    assert_not Manual.for(:lideres).reload.available?
  end

  test "a PDF already uploaded straight to the bucket is saved by its signed reference" do
    sign_in_as(users(:one))
    blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture("manual.pdf").open, filename: "manual.pdf", content_type: "application/pdf")

    patch upload_manual_path(:joven), params: { file: blob.signed_id }
    assert_redirected_to manuals_path
    assert_equal blob, Manual.for(:joven).file.blob
  end

  test "only a PDF is taken" do
    sign_in_as(users(:one))

    upload(:joven, "tiny.png", "image/png")
    assert_redirected_to manuals_path
    assert_match "debe ser un PDF", flash[:alert]
    assert_not Manual.for(:joven).available?
  end

  test "without full access nobody uploads a manual" do
    sign_in_as(@counselor)
    upload(:joven)

    assert_redirected_to manuals_path
    assert_not Manual.for(:joven).available?

    sign_in_as(@joven)
    upload(:joven)
    assert_redirected_to dashboard_path
  end

  test "only the superadmin changes the Gospel Library links" do
    sign_in_as(users(:one))
    get manuals_path
    assert_select "a[href='#{links_manuals_path}']"

    patch links_manuals_path, params: { links: { musica: "https://www.churchofjesuschrist.org/study/music/fsy-2026?lang=spa", predicad: "" } }
    assert_redirected_to manuals_path
    get manuals_path
    assert_select "[data-manual-library='musica'][href='https://www.churchofjesuschrist.org/study/music/fsy-2026?lang=spa']"
    assert_select "[data-manual-library='predicad']", false, "vacío lo quita"

    patch links_manuals_path, params: { links: { fortaleza: "no es un enlace" } }
    assert_redirected_to links_manuals_path
    assert_equal ManualLinks::LINKS["fortaleza"][:default], ManualLinks.url("fortaleza")

    sign_in_as(User.create!(email_address: "roberto@fsy.com", password: "Director1!", participant: @director))
    get links_manuals_path
    assert_redirected_to manuals_path
    patch links_manuals_path, params: { links: { musica: "https://example.com" } }
    assert_redirected_to manuals_path
    assert_equal "https://www.churchofjesuschrist.org/study/music/fsy-2026?lang=spa", ManualLinks.url("musica")
  end

  test "a manual is read inside the app, and the joven only opens theirs" do
    Manual.for(:joven).tap { |manual| manual.file.attach(fixture_file_upload("manual.pdf", "application/pdf")) }.save!
    Manual.for(:lideres).tap { |manual| manual.file.attach(fixture_file_upload("manual.pdf", "application/pdf")) }.save!
    sign_in_as(@joven)

    get read_manual_path(:joven)
    assert_response :success
    assert_select "[data-controller='pdf-reader'][data-manual-reader='joven']" do |reader|
      assert_match %r{/rails/active_storage/blobs/proxy/}, reader.first["data-pdf-reader-url-value"]
      assert_match "pdfjs-worker", reader.first["data-pdf-reader-worker-value"]
    end
    assert_select "nav[data-bottom-nav]", false, "el lector lleva su propia barra"

    get read_manual_path(:lideres)
    assert_redirected_to manuals_path
  end

  test "a manual without its PDF can't be opened" do
    sign_in_as(@counselor)

    get read_manual_path(:lideres)
    assert_redirected_to manuals_path
    assert_match "todavía no está disponible", flash[:alert]
  end
end
