require "application_system_test_case"

class ParticipantPermissionsTest < ApplicationSystemTestCase
  setup do
    @own_company = Company.create!(number: 1)
    @other_company = Company.create!(number: 2)
    @own_company.memberships.create!(participant: participants(:maria))

    @own_joven = participants(:juan)
    @own_joven.update!(company: @own_company)
    @other_joven = Participant.create!(first_name: "Ana", last_name: "Diez", age: 15, stake: "villa_flor",
                                       shirt_number: "s", gender: "M", rol: "joven", company: @other_company)
  end

  test "con acceso total se edita la ficha de un joven desde su perfil" do
    sign_in_as(users(:one))

    visit participant_path(@own_joven)
    click_on "Editar"
    fill_in "participant_first_name", with: "Juan Carlos"
    click_on "Actualizar"

    assert_text "Actualizado exitosamente."
    assert_text "Juan Carlos"
    assert_equal "Juan Carlos", @own_joven.reload.first_name
  end

  test "un consejero edita a los jóvenes de su compañía pero no a los de otra" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)),
               password: "Consejera1!")

    visit participant_path(@own_joven)
    assert_link "Editar"

    visit participant_path(@other_joven)
    assert_text "Ana Diez"
    assert_no_link "Editar"
  end

  test "un consejero que abre a mano la edición de otra compañía es devuelto con un aviso" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)),
               password: "Consejera1!")

    visit edit_participant_path(@other_joven)

    assert_current_path participants_path
    assert_text "No estás autorizado para editar este registro"
  end
end
