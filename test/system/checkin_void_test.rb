require "application_system_test_case"

# Llega alguien con el gafete de otra persona: desde el escáner se anula el último registro, con motivo.
class CheckinVoidTest < ApplicationSystemTestCase
  setup do
    AppSetting[ScanWindow::ARRIVAL_KEY] = "open"
    @andrea = Participant.create!(first_name: "Andrea", last_name: "Chavarría", age: 15, stake: "villa_flor",
                                  shirt_number: "s", gender: "M", rol: "joven")
    @andrea.update_columns(code: "P-0421")
  end

  test "the last scan is voided from below the camera, with a reason" do
    sign_in_as(users(:one))
    visit checkins_path
    assert_text "Padrón actualizado"

    fill_in "Código del gafete", with: "421"
    click_on "Registrar"

    within("[data-last-scan]") do
      assert_text "Andrea Chavarría"
      assert_selector "[data-gender-chip]", text: /Mujer/i
      click_on "Anular"
    end

    within("dialog[data-void-dialog]") do
      assert_text "¿Anular la llegada de Andrea Chavarría?"
      choose "No era la persona"
      fill_in "Detalles", with: "Llegó un muchacho con su gafete"
      save_screenshot(File.join(ENV["SCREENSHOTS"], "anular-dialogo.png")) if ENV["SCREENSHOTS"]
      click_on "Anular"
    end

    within("[data-last-scan]") { assert_text "Anulado" }
    assert_selector "[data-arrived]", text: "0"
    save_screenshot(File.join(ENV["SCREENSHOTS"], "anular-hecho.png")) if ENV["SCREENSHOTS"]

    assert_no_selector "[data-pending]:not([hidden])", wait: 5
    assert_not @andrea.reload.arrived?
    assert_match(/No era la persona: Llegó un muchacho con su gafete/, AuditLog.registro.sole.summary)

    # La dueña verdadera llega después y entra normal.
    fill_in "Código del gafete", with: "421"
    click_on "Registrar"
    within("[data-last-scan]") { assert_text "Registrado" }
    assert_selector "[data-arrived]", text: "1"
  end
end
