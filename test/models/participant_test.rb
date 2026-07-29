
require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  test "es válido con todos los atributos requeridos" do
    # 1. Preparar datos (Arrange)
    participant = Participant.new(
      first_name: "Juan",
      last_name: "Pérez",
      age: 20,
      stake: "bello_horizonte",
      shirt_number: "m",
      genre: "H"
    )

    # 2 & 3. Actuar y Afirmar (Act & Assert)
    assert participant.valid?, "El participante debería ser válido con todos sus datos"
  end

  test "es inválido sin nombre (first_name)" do
    participant = Participant.new(last_name: "Pérez", age: 20)

    assert_not participant.valid?, "El participante no debería ser válido sin nombre"
    assert participant.errors[:first_name].any?, "Debería haber un error en el campo first_name"
  end

  test "es inválido con una edad fuera de rango" do
    participant = Participant.new(
      first_name: "Juan", last_name: "Pérez", age: 150, # ¡Edad irreal!
      stake: "bello_horizonte", shirt_number: "m", genre: "H"
    )

    assert_not participant.valid?
    assert participant.errors[:age].any?
  end
end
