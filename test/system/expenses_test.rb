require "application_system_test_case"

class ExpensesTest < ApplicationSystemTestCase
  setup do
    area = LogisticsArea.create!(name: "Finanzas", finance: true)
    finance = Participant.create!(first_name: "Fina", last_name: "Cuentas", age: 30, stake: "villa_flor", shirt_number: "m",
                                  gender: "M", rol: :logistica, logistics_area: area)
    director = Participant.create!(first_name: "Dire", last_name: "Logística", age: 45, stake: "villa_flor", shirt_number: "l",
                                   gender: "H", rol: :director_logistica)
    @finance_user = User.create!(email_address: "fina@fsy.com", password: "Finanzas1!", participant: finance)
    @director_user = User.create!(email_address: "dire@fsy.com", password: "Director1!", participant: director)
    FinanceSettings.budget_cents = 500_000
  end

  test "un gasto se presenta, lo aprueba otra persona y se consolida con su factura" do
    sign_in_as(@finance_user, password: "Finanzas1!")
    visit new_expense_path
    fill_in "Concepto", with: "Agua"
    fill_in "Monto", with: "1500"
    # "Presentar gasto" en main y "Presentar" con los textos cortos: el clic sirve para los dos.
    click_on "Presentar"

    assert_text "Gasto presentado. Ahora lo tiene que aprobar otra persona."
    expense = Expense.find_by!(concept: "Agua")
    # Quien lo presenta no lo aprueba.
    within("[data-next-step='approve']") do
      assert_text "lo aprueban el matrimonio director o el director de logística"
      assert_no_button "Aprobar"
    end
    sign_out

    sign_in_as(@director_user, password: "Director1!")
    visit expense_path(expense)
    click_on "Aprobar"
    assert_text "Gasto aprobado. Falta la factura para consolidarlo."
    sign_out

    sign_in_as(@finance_user, password: "Finanzas1!")
    visit expense_path(expense)
    attach_file "Foto de la factura", file_fixture("factura.png")
    fill_in "consolidate_actual_amount", with: "1420"
    click_on "Consolidar"

    assert_text "Gasto consolidado con su factura."
    assert_selector "[data-receipt] img"
    assert_selector "[data-timeline] li", count: 3
    assert expense.reload.consolidated?
    assert_equal 142_000, expense.actual_cents
  end

  test "un gasto rechazado pide el motivo y queda cerrado" do
    sign_in_as(@finance_user, password: "Finanzas1!")
    visit new_expense_path
    fill_in "Concepto", with: "Globos"
    fill_in "Monto", with: "300"
    click_on "Presentar"
    assert_text "Gasto presentado."
    expense = Expense.find_by!(concept: "Globos")
    sign_out

    sign_in_as(@director_user, password: "Director1!")
    visit expense_path(expense)
    fill_in "Motivo del rechazo", with: "No está en el presupuesto"
    click_on "Rechazar"

    assert_text "Gasto rechazado."
    assert expense.reload.rejected?
    assert_no_button "Aprobar"
  end
end
