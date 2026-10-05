require "test_helper"

class InfirmaryNoteTest < ActiveSupport::TestCase
  setup do
    @joven = participants(:juan)
    @visit = InfirmaryVisit.admit_directly(@joven, by: nil, reason: "fiebre").tap(&:start)
    @nurse = Participant.create!(first_name: "Patricia", last_name: "Lacayo", age: 40, stake: "bello_horizonte", ward: "la_rotonda",
                                 shirt_number: "m", gender: "M", rol: "logistica")
    pharmacy = Inventory.create!(name: "Medicamentos", infirmary: true, icon: "package", color: "primary")
    @paracetamol = pharmacy.items.create!(name: "Acetaminofén 500 mg", unit: "tabletas")
    @paracetamol.adjust!(delta: 10, participant: @nurse, reason: :inicial)
    @ibuprofen = pharmacy.items.create!(name: "Ibuprofeno 400 mg", unit: "tabletas")
    @ibuprofen.adjust!(delta: 1, participant: @nurse, reason: :inicial)
    materials = Inventory.create!(name: "Materiales", icon: "package", color: "primary")
    @shirt = materials.items.create!(name: "Camiseta", unit: "u").tap { |item| item.adjust!(delta: 5, participant: @nurse, reason: :inicial) }
  end

  test "giving a medicine takes it out of the infirmary inventory, tied to the note" do
    note = medicine_note(doses: [ { item_id: @paracetamol.id, quantity: "2" } ], body: "Con agua")

    assert note.save_with_doses(by: @nurse)
    assert_equal 8, @paracetamol.reload.quantity
    movement = @paracetamol.movements.first
    assert movement.enfermeria?
    assert_equal note, movement.infirmary_note
    assert_equal [ "Acetaminofén 500 mg × 2 tabletas" ], note.reload.dose_labels
  end

  test "nothing is saved nor taken out when one of the medicines isn't enough" do
    note = medicine_note(doses: [ { item_id: @paracetamol.id, quantity: "2" }, { item_id: @ibuprofen.id, quantity: "3" } ])

    assert_no_difference -> { InfirmaryNote.count } do
      assert_not note.save_with_doses(by: @nurse)
    end
    assert_includes note.errors.full_messages, "Ibuprofeno 400 mg: pides 3 y en el inventario hay 1"
    assert_equal 10, @paracetamol.reload.quantity
  end

  test "only infirmary inventories, whole quantities, and some medicine named" do
    assert_not medicine_note(doses: [ { item_id: @shirt.id, quantity: "1" } ]).save_with_doses(by: @nurse)
    assert_equal 5, @shirt.reload.quantity

    half = medicine_note(doses: [ { item_id: @paracetamol.id, quantity: "0.5" } ])
    assert_not half.save_with_doses(by: @nurse)
    assert_includes half.errors.full_messages, "Acetaminofén 500 mg: la cantidad debe ser un número entero mayor que cero"

    empty = medicine_note(doses: [])
    assert_not empty.save_with_doses(by: @nurse)
    assert_includes empty.errors.full_messages, "elige el medicamento que se le dio (o escríbelo si no está en el inventario)"

    assert medicine_note(doses: [], body: "Su propio inhalador, 2 disparos").save_with_doses(by: @nurse), "a medicine outside the inventory is written"
  end

  test "a plain note ignores any medicine left in the form" do
    note = @visit.notes.build(body: "Duerme", author: @nurse, author_name: "Patricia Lacayo")
    note.doses_to_give = [ { item_id: @paracetamol.id, quantity: "2" } ]

    assert note.save_with_doses(by: @nurse)
    assert_equal 10, @paracetamol.reload.quantity
  end

  test "the infirmary reason is never offered in a manual adjustment" do
    assert_not_includes InventoryMovement.reasons_for(:out).keys, "enfermeria"
  end

  private
    def medicine_note(doses:, body: nil)
      @visit.notes.build(medication: true, body: body, author: @nurse, author_name: "Patricia Lacayo").tap { |note| note.doses_to_give = doses }
    end
end
