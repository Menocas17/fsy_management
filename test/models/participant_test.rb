
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

  test "a counselor's company on the ficha and the company's staff stay the same from either side" do
    first = Company.create!(number: 1)
    second = Company.create!(number: 2)
    maria = participants(:maria)

    maria.update!(company: first)
    assert_equal [ maria ], first.reload.counselors.to_a, "editing the ficha staffs the company"

    maria.update!(company: second)
    assert_empty first.reload.counselors
    assert_equal [ maria ], second.reload.counselors.to_a

    maria.update!(rol: :auxiliar)
    assert_empty second.reload.counselors, "no longer a counselor, no longer staffed"

    maria.update!(rol: :consejero, company: nil)
    first.memberships.create!(participant: maria)
    assert_equal first, maria.reload.company, "staffing from the company fills the ficha"
    first.memberships.find_by!(participant: maria).destroy
    assert_nil maria.reload.company
  end

  test "a company keeps one counselor per gender when the ficha is edited" do
    company = Company.create!(number: 1)
    participants(:maria).update!(company: company)
    other = Participant.create!(first_name: "Rosa", last_name: "Díaz", age: 30, stake: "bello_horizonte", ward: "la_rotonda",
                                shirt_number: "m", gender: "M", rol: "consejero")

    assert_not other.update(company: company)
    assert_match "Compañía 1 ya tiene consejera: María García", other.errors.full_messages.to_sentence
  end

  test "each stake offers only its own wards" do
    juan = participants(:juan)

    assert_not juan.update(ward: "villa_venezuela")
    assert_match "Barrio Villa Venezuela no es de la Estaca Bello Horizonte", juan.errors.full_messages.to_sentence
  end

  test "staff may come from a stake that doesn't take part, written by hand; jóvenes may not" do
    maria = participants(:maria)
    assert maria.update(stake: Participant::OTHER_STAKE, other_stake: "Estaca Managua Sur", other_ward: "Barrio Altamira")
    assert_equal [ nil, nil, "Estaca Managua Sur", "Barrio Altamira" ], [ maria.stake, maria.ward, maria.stake_name, maria.ward_name ]
    assert_equal Participant::OTHER_STAKE, maria.stake_choice

    maria.update!(stake: "las_americas", ward: "las_mercedes")
    assert_nil maria.reload.other_stake, "choosing a stake that takes part drops the written one"

    juan = participants(:juan)
    assert_not juan.update(stake: Participant::OTHER_STAKE, other_stake: "Estaca León")
    assert_match "solo se acepta para el staff", juan.errors.full_messages.to_sentence
  end

  test "the age comes from the birth date, counted on the first day of the event" do
    juan = participants(:juan)
    event = Rails.configuration.x.event_start_on

    juan.update!(birth_date: event.prev_year(16))
    assert_equal 16, juan.age
    juan.update!(birth_date: event.prev_year(16) + 1)
    assert_equal 15, juan.age, "one day short of the birthday"

    assert_not Participant.new(first_name: "Sin", last_name: "Fecha", stake: "villa_flor", shirt_number: "m", gender: "H").valid?
  end

  test "the nickname is the preferred name only when it differs from the first name" do
    juan = participants(:juan)

    juan.preferred_name = "juan"
    assert_nil juan.nickname
    juan.preferred_name = "Juancho"
    assert_equal "Juancho", juan.nickname
  end
end
