require "test_helper"

class InventoryTest < ActiveSupport::TestCase
  setup do
    @inventory = Inventory.create!(name: "Materiales", icon: "package", color: "primary")
    @item = @inventory.items.create!(name: "Manillas de tela", unit: "u", minimum: 80)
  end

  test "derives a code prefix from the name and never repeats it" do
    assert_equal "MAT", @inventory.code_prefix
    assert_equal "MATE", Inventory.create!(name: "Materiales de apoyo").code_prefix
  end

  test "numbers the items of each inventory in sequence" do
    assert_equal "MAT-0001", @item.code
    assert_equal "MAT-0002", @inventory.items.create!(name: "Cuadernos").code

    medicines = Inventory.create!(name: "Medicinas")
    assert_equal "MED-0001", medicines.items.create!(name: "Acetaminofén").code
  end

  test "the stock is whatever the movements add up to" do
    @item.adjust!(delta: 100, participant: participants(:maria), reason: :compra)
    assert_equal 100, @item.reload.quantity

    @item.adjust!(delta: -40, participant: participants(:maria), reason: :entrega)
    assert_equal 60, @item.reload.quantity
  end

  test "refuses to take out more than there is" do
    @item.adjust!(delta: 10, participant: participants(:maria), reason: :compra)

    assert_raises(ActiveRecord::RecordInvalid) do
      @item.adjust!(delta: -11, participant: participants(:maria), reason: :entrega)
    end
    assert_equal 10, @item.reload.quantity
  end

  test "movements keep the name of whoever made them" do
    movement = @item.adjust!(delta: 5, participant: participants(:maria), reason: :compra)

    assert_equal participants(:maria).full_name, movement.participant_name
    assert_equal "+5", movement.delta_label
    assert movement.source_manual?
  end

  test "reports its status against the minimum" do
    assert_equal :out, @item.status

    @item.adjust!(delta: 80, participant: nil, reason: :inicial)
    assert_equal :low, @item.reload.status, "igual al mínimo ya es por agotarse"

    @item.adjust!(delta: 1, participant: nil, reason: :compra)
    assert_equal :ok, @item.reload.status
  end

  test "counts what is running out in each inventory" do
    full = @inventory.items.create!(name: "Cuadernos", minimum: 10)
    full.adjust!(delta: 100, participant: nil, reason: :inicial)
    @item.adjust!(delta: 20, participant: nil, reason: :inicial)

    assert_equal [ @item ], @inventory.reload.low_stock_items
    assert_empty @inventory.out_of_stock_items
  end

  test "searching finds items by name, code or location" do
    @item.update!(location: "Bodega 2")

    assert_includes @inventory.items.search("manilla"), @item
    assert_includes @inventory.items.search("MAT-0001"), @item
    assert_includes @inventory.items.search("bodega"), @item
    assert_empty @inventory.items.search("camisetas")
  end

  test "a reason only applies in the direction that makes sense" do
    @item.adjust!(delta: 100, participant: nil, reason: :compra)

    error = assert_raises(ActiveRecord::RecordInvalid) do
      @item.adjust!(delta: 20, participant: nil, reason: :entrega)
    end
    assert_match(/no aplica para sumar/, error.record.errors.full_messages.to_sentence)

    assert_raises(ActiveRecord::RecordInvalid) do
      @item.adjust!(delta: -5, participant: nil, reason: :compra)
    end

    # El conteo físico sirve en los dos sentidos, que para eso se cuenta.
    assert @item.adjust!(delta: -5, participant: nil, reason: :conteo)
    assert @item.adjust!(delta: 5, participant: nil, reason: :conteo)
  end

  test "the modal is offered only the reasons that fit the sign" do
    assert_equal %w[compra devolucion conteo], InventoryMovement.reasons_for(:in).keys
    assert_equal %w[entrega perdida conteo], InventoryMovement.reasons_for(:out).keys
    assert_not_includes InventoryMovement.reasons_for(:in).keys, "inicial", "lo pone la creación del artículo"
  end

  test "the QR carries the item code" do
    assert_equal "MAT-0001", @item.qr_payload
  end
end
