
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "contraseña válida si cumple todos los requisitos" do
    user = User.new(email_address: "staff@fsy.com", password: "Password123!")
    assert user.valid?
  end

  test "contraseña inválida si no tiene números" do
    user = User.new(email_address: "staff@fsy.com", password: "Password!")

    assert_not user.valid?
    # Verificamos que el mensaje de error incluya la palabra "número"
    assert_includes user.errors[:password].join, "número"
  end

  test "el director de logística administra personal y muestra su rol en español" do
    participants(:maria).update!(rol: "director_logistica")
    user = User.new(participant: participants(:maria))

    assert user.admin_or_staff_manager?
    assert_equal "Director de logística", user.role_label
    assert_equal "Superadmin", User.new.role_label
  end

  test "contraseña inválida si no tiene mayúsculas" do
    user = User.new(email_address: "staff@fsy.com", password: "password123!")

    assert_not user.valid?
    assert_includes user.errors[:password].join, "mayúscula"
  end

  test "superadmin es la columna, no la falta de participante" do
    assert users(:one).superadmin?
    assert users(:one).full_access?

    orphan = User.new(email_address: "huerfano@fsy.com", password: "Password123!")
    assert_not orphan.superadmin?
    assert_not orphan.full_access?
    assert_not orphan.alert_manager?
    assert_not orphan.agenda_manager?
    assert_not orphan.linked?
  end

  test "borrar la ficha borra su cuenta en vez de volverla superadmin" do
    maria = participants(:maria)
    user = User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: maria)
    user.sessions.create!

    maria.destroy

    assert_not User.exists?(user.id)
    assert_equal 0, Session.where(user_id: user.id).count
  end

  test "el correo es obligatorio, válido y único sin importar mayúsculas" do
    assert_not User.new(email_address: "", password: "Password123!").valid?
    assert_not User.new(email_address: "sin-arroba", password: "Password123!").valid?

    duplicate = User.new(email_address: " ADMIN@fsy.com ", password: "Password123!")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email_address], "ya está en uso"
  end

  test "un participante tiene a lo sumo una cuenta" do
    User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria))
    second = User.new(email_address: "maria2@fsy.com", password: "Consejera1!", participant: participants(:maria))

    assert_not second.valid?
    assert second.errors.key?(:participant_id)
  end

  test "la dirección y coordinación entran a todo, salvo presentar o aprobar gastos" do
    coordinator = Participant.create!(first_name: "Pedro", last_name: "Mora", age: 40, stake: "las_americas",
                                      shirt_number: "m", gender: "H", rol: :coordinador)
    user = User.new(participant: coordinator)

    assert user.full_access?
    assert user.scan_manager?
    assert user.infirmary_operator?
    assert user.finance_configurator?
    assert user.finance_viewer?
    assert_not user.finance_operator?, "presentar gastos sigue siendo del área de Finanzas y el director de logística"
    assert_not user.expense_approver?, "aprobar sigue siendo del superadmin, el director y el director de logística"
  end
end
