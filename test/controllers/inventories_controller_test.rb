require "test_helper"

class InventoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @inventory = Inventory.create!(name: "Materiales", icon: "package", color: "primary")
    @item = @inventory.items.create!(name: "Manillas de tela", unit: "u", minimum: 80)
    @item.adjust!(delta: 62, participant: nil, reason: :inicial)
  end

  test "the index lists every inventory with what is running out" do
    get inventories_path

    assert_response :success
    assert_select "a[href='#{inventory_path(@inventory)}']"
    assert_select "[data-inventory-count='MAT']", text: /1/
    assert_select "a[href='#{scan_inventories_path}']"
  end

  test "an inventory shows its items and the adjust buttons" do
    get inventory_path(@inventory)

    assert_response :success
    assert_select "[data-item-code='MAT-0001'] [data-item-quantity]", text: /62/
    assert_select "button[data-adjust-code='MAT-0001'][data-adjust-sign='-1']"
    assert_select "button[data-adjust-code='MAT-0001'][data-adjust-sign='1']"
    assert_select "[data-inventory-adjust-target='modal']"
  end

  test "searching and filtering narrow the list" do
    @inventory.items.create!(name: "Cuadernos FSY", minimum: 10).adjust!(delta: 400, participant: nil, reason: :inicial)

    get inventory_path(@inventory, query: "cuaderno")
    assert_select "[data-item-code]", 1

    get inventory_path(@inventory, filter: "low")
    assert_select "[data-item-code='MAT-0001']", 1
    assert_select "[data-item-code]", 1, "solo el que está por agotarse"
  end

  test "adding an item registers its starting stock as the first movement" do
    assert_difference -> { InventoryItem.count }, 1 do
      post inventory_items_path(@inventory), params: {
        inventory_item: { name: "Marcadores", unit: "u", minimum: 12, starting_quantity: 30 }
      }
    end

    item = InventoryItem.find_by(name: "Marcadores")
    assert_redirected_to inventory_item_path(item)
    assert_equal 30, item.quantity
    assert_equal "inicial", item.movements.first.reason
  end

  test "the item page shows its movements and its QR" do
    get inventory_item_path(@item)

    assert_response :success
    assert_select "[data-item-quantity]", text: /62/
    assert_select "svg[role='img']", 1, "el QR del artículo"
    assert_includes response.body, "Inventario inicial"
  end

  test "adjusting from the table moves the stock and writes the history" do
    assert_difference -> { @item.movements.count }, 1 do
      post inventory_item_movements_path(@item), params: { sign: "-1", quantity: 40, reason: "entrega", note: "Compañía 4" }
    end

    assert_equal 22, @item.reload.quantity
    movement = @item.movements.first
    assert_equal(-40, movement.delta)
    assert_equal "Compañía 4", movement.note
    assert_equal "Administrador del sistema", movement.participant_name
  end

  test "after adjusting from a scan the dialog does not reopen on top of the result" do
    post inventory_item_movements_path(@item),
         params: { sign: "1", quantity: 5, reason: "compra", source: "escaneo" },
         headers: { "HTTP_REFERER" => inventory_item_path(@item, ajuste: 1, origen: "escaneo") }

    assert_redirected_to inventory_item_path(@item, escaneado: 1)
    assert_equal 67, @item.reload.quantity
    assert_equal "escaneo", @item.movements.first.source
    assert_match(/queda en 67/, flash[:notice])
  end

  test "after a scanned adjustment the next box is one tap away" do
    post inventory_item_movements_path(@item),
         params: { sign: "1", quantity: 1, reason: "compra", source: "escaneo" },
         headers: { "HTTP_REFERER" => inventory_item_path(@item, ajuste: 1, origen: "escaneo") }
    follow_redirect!

    assert_select "[data-scan-again]", 1
    assert_select "[data-scan-again] a[href='#{scan_inventories_path}']", text: /Escanear otro/
  end

  test "a manual adjustment does not offer to keep scanning" do
    post inventory_item_movements_path(@item),
         params: { sign: "1", quantity: 1, reason: "compra" },
         headers: { "HTTP_REFERER" => inventory_item_path(@item) }
    follow_redirect!

    assert_select "[data-scan-again]", 0
  end

  test "adjusting from the table keeps you where you were, search included" do
    post inventory_item_movements_path(@item),
         params: { sign: "-1", quantity: 2, reason: "entrega" },
         headers: { "HTTP_REFERER" => inventory_path(@inventory, query: "manilla", ajuste: 1) }

    assert_redirected_to inventory_path(@inventory, query: "manilla")
  end

  test "it refuses to take out more than there is" do
    post inventory_item_movements_path(@item), params: { sign: "-1", quantity: 100, reason: "entrega" }

    assert_equal 62, @item.reload.quantity
    assert_match(/no puedes restar más/, flash[:alert])
  end

  test "a scan lands on the item with the dialog open" do
    get lookup_inventory_items_path(code: "mat-0001")

    assert_redirected_to inventory_item_path(@item, ajuste: 1, origen: "escaneo")
  end

  test "an unknown code says so instead of a 404" do
    get lookup_inventory_items_path(code: "NADA-9999")

    assert_redirected_to scan_inventories_path
    assert_match(/No encontramos/, flash[:alert])
  end

  test "a logistics member adjusts stock but cannot create inventories" do
    member = Participant.create!(first_name: "Luis", last_name: "Mena", age: 30, stake: "las_americas",
                                 shirt_number: "l", gender: "H", rol: :logistica)
    sign_in_as(User.create!(email_address: "luis@fsy.com", password: "Logistica1!", participant: member))

    post inventory_item_movements_path(@item), params: { sign: "1", quantity: 10, reason: "compra" }
    assert_equal 72, @item.reload.quantity
    assert_equal member.full_name, @item.movements.first.participant_name

    get new_inventory_path
    assert_redirected_to inventories_path

    assert_no_difference -> { Inventory.count } do
      post inventories_path, params: { inventory: { name: "Pirata" } }
    end
  end

  test "a consejero cannot reach the inventory at all" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get inventories_path
    assert_redirected_to dashboard_path

    assert_no_difference -> { @item.movements.count } do
      post inventory_item_movements_path(@item), params: { sign: "1", quantity: 5, reason: "compra" }
    end
  end

  test "the inventory and label PDFs come out" do
    { inventory_reports_path => "inventario", labels_reports_path => "etiquetas" }.each do |path, stem|
      get path

      assert_response :success
      assert_equal "application/pdf", response.media_type
      assert response.body.start_with?("%PDF-"), "#{path} no devolvió un PDF"
      assert_match(/filename="#{stem}-/, response.headers["Content-Disposition"])
    end
  end

  test "the sidebar calls it Inventario, not Logística" do
    get inventories_path

    assert_select "aside a[aria-current='page']", text: "Inventario"
    assert_select "aside", { text: /Logística/, count: 0 }
  end
end
