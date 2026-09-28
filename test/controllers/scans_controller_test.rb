require "test_helper"

class ScansControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @joven = participants(:juan)
  end

  test "the scanner page loads" do
    get scan_path

    assert_response :success
    assert_select "[data-controller='qr-scanner']"
  end

  test "a badge, whole URL or bare id, opens that person's ficha" do
    get scan_lookup_path(code: participant_url(@joven))
    assert_redirected_to participant_path(@joven, from: "escaner", return_to: scan_path)

    get scan_lookup_path(code: @joven.id)
    assert_redirected_to participant_path(@joven, from: "escaner", return_to: scan_path)
  end

  test "an inventory label opens the item for those who handle inventory" do
    item = Inventory.create!(name: "Materiales").items.create!(name: "Tijeras", unit: "u")

    get scan_lookup_path(code: item.code.downcase)
    assert_redirected_to inventory_item_path(item, ajuste: 1, origen: "escaneo")
  end

  test "an unknown code goes back to the scanner with a notice" do
    get scan_lookup_path(code: "no-existe")

    assert_redirected_to scan_path
    assert_match(/no es de ningún gafete/, flash[:alert])
  end

  test "the ficha opened from a scanner goes back to that scanner" do
    training = Training.create!(name: "Hoy", held_on: Date.current)
    back = checkins_path(training_id: training.id)

    get participant_path(@joven, from: "escaner", return_to: back)

    assert_select "a[title='Volver a Escáner'][href='#{back}']"
  end

  test "the short badge code opens the ficha, and the QR dialog shows it" do
    @joven.update_columns(code: "P-0421")

    get scan_lookup_path(code: "p421")
    assert_redirected_to participant_path(@joven, from: "escaner", return_to: scan_path)

    get participant_path(@joven)
    assert_select "dialog[data-dialog-name='qr'] [data-badge-code]", text: "P-0421"
  end
end
