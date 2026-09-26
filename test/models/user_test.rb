
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
end
