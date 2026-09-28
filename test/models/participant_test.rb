
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
      gender: "H"
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
      stake: "bello_horizonte", shirt_number: "m", gender: "H"
    )

    assert_not participant.valid?
    assert participant.errors[:age].any?
  end

  test "each new participant gets the next short badge code" do
    Participant.where.not(code: nil).update_all(code: nil)
    Participant.first.update_columns(code: "P-0041")

    created = Participant.create!(first_name: "Nuevo", last_name: "Código", age: 15, stake: "villa_flor", shirt_number: "m", gender: "H")

    assert_equal "P-0042", created.code
  end

  test "a badge code is found however it is typed" do
    participant = participants(:juan)
    participant.update_columns(code: "P-0421")

    [ "P-0421", "p0421", "p 421", "421", "0421" ].each do |typed|
      assert_equal participant, Participant.find_by_badge(typed), typed
    end
    assert_equal participant, Participant.find_by_badge("https://fsy.example/participants/#{participant.id}")
    assert_nil Participant.normalize_code("MAT-0042"), "an inventory code is not a badge code"
  end

  test "there is only one man and one woman in each leadership role" do
    attrs = { last_name: "Líder", age: 45, stake: "villa_flor", shirt_number: "l" }
    Participant.create!(attrs.merge(first_name: "Luis", gender: "H", rol: :coordinador))
    Participant.create!(attrs.merge(first_name: "Ana", gender: "M", rol: :coordinador))

    third = Participant.new(attrs.merge(first_name: "Beto", gender: "H", rol: :coordinador))
    refute third.valid?
    assert_match(/Ya hay coordinador hombre: Luis Líder/, third.errors.full_messages.to_sentence)

    counselor = participants(:maria)
    refute counselor.update(rol: :coordinador, gender: "M"), "nor can an edit sneak in a third one"
  end
end
