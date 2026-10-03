require "application_system_test_case"

class InventoryTest < ApplicationSystemTestCase
  setup do
    @inventory = Inventory.create!(name: "Materiales", icon: "package", color: "primary")
    @item = @inventory.items.create!(name: "Manillas de tela", unit: "u", minimum: 80)
    @item.adjust!(delta: 62, participant: nil, reason: :inicial)
    sign_in_as(users(:one))
  end

  test "sumar desde la tabla muestra cuánto queda y deja el movimiento en el historial" do
    visit inventory_path(@inventory)

    find("button[data-adjust-code='MAT-0001'][data-adjust-sign='1']").click
    fill_in "Cantidad", with: "10"
    assert_selector "[data-inventory-adjust-target='preview']", text: "72"
    click_on "Guardar ajuste"

    assert_text "+10 u · queda en 72 u"
    assert_selector "[data-item-code='MAT-0001'] [data-item-quantity]", text: "72"
    assert_equal 72, @item.reload.quantity
    assert_equal 2, @item.movements.count
  end

  test "restar baja la existencia" do
    visit inventory_path(@inventory)

    find("button[data-adjust-code='MAT-0001'][data-adjust-sign='-1']").click
    fill_in "Cantidad", with: "5"
    click_on "Guardar ajuste"

    assert_text "-5 u · queda en 57 u"
    assert_equal 57, @item.reload.quantity
  end

  test "escribir el código lleva a la ficha del artículo con el ajuste abierto" do
    visit scan_inventories_path

    fill_in "Código del artículo", with: "mat-0001"
    click_on "Buscar"

    assert_current_path inventory_item_path(@item, ajuste: 1, origen: "escaneo")
    assert_selector "dialog[open]", text: "Guardar ajuste"
  end

  test "un código que no existe vuelve al escáner con un aviso" do
    visit scan_inventories_path

    fill_in "Código del artículo", with: "MAT-9999"
    click_on "Buscar"

    assert_text "No encontramos ningún artículo con el código MAT-9999."
    assert_current_path scan_inventories_path
  end
end
