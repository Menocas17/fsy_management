require "test_helper"
require "roo"

class ExpenseReportsTest < ActionDispatch::IntegrationTest
  setup do
    area = LogisticsArea.create!(name: "Finanzas", finance: true)
    @finance = Participant.create!(first_name: "Fina", last_name: "Cuentas", age: 30, stake: "villa_flor", shirt_number: "m",
                                   gender: "M", rol: :logistica, logistics_area: area)
    @director = Participant.create!(first_name: "Dire", last_name: "Logística", age: 45, stake: "villa_flor", shirt_number: "l",
                                    gender: "H", rol: :director_logistica)
    @finance_user = User.create!(email_address: "fina@fsy.com", password: "Finanzas1!", participant: @finance)
    FinanceSettings.budget_cents = 1_000_000
    FinanceSettings.usd_rate = 36.5
    food = ExpenseCategory.create!(name: "Alimentación", budget_cents: 300_000, icon: "utensils", color: "orange")

    @with_receipt = present("Agua", 150_000, category: food)
    @with_receipt.approve(@director)
    @with_receipt.consolidate(@finance, receipt: Rack::Test::UploadedFile.new(file_fixture("factura.png"), "image/png"),
                              actual_cents: 142_000, spent_on: Date.current, payment_method: "efectivo")

    @justified = present("Hielo", 20_000, category: food)
    @justified.approve(@director)
    @justified.justify(@finance, text: "Vendedor ambulante", actual_cents: 20_000, spent_on: nil, payment_method: "efectivo")
    @justified.approve_justification(@director)

    @waiting = present("Proyector", 10_000, currency: "USD", rate: 36.5)
    @waiting.approve(@director)
  end

  test "the accountability PDF comes out for those who see finances" do
    sign_in_as(@finance_user)

    get expenses_reports_path

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
    assert_match(/rendicion-de-gastos-.*\.pdf/, response.headers["Content-Disposition"])
  end

  test "the Excel has the summary, every expense with numeric amounts, and the categories" do
    sign_in_as(@finance_user)

    get expenses_workbook_reports_path

    assert_response :success
    assert_equal ExpensesWorkbook::CONTENT_TYPE, response.media_type
    assert_match(/attachment/, response.headers["Content-Disposition"])

    Tempfile.create([ "rendicion", ".xlsx" ]) do |file|
      file.binmode
      file.write(response.body)
      file.flush
      book = Roo::Excelx.new(file.path)
      assert_equal [ "Resumen", "Gastos", "Por categoría" ], book.sheets

      gastos = book.sheet("Gastos")
      assert_equal 4, gastos.last_row, "header plus the three expenses"
      agua = (2..gastos.last_row).map { |r| gastos.row(r) }.find { |row| row[1] == "Agua" }
      assert_equal 1420.0, agua[9], "real amount in córdobas, as a number"
      assert_equal "Factura", agua[12]
      hielo = (2..gastos.last_row).map { |r| gastos.row(r) }.find { |row| row[1] == "Hielo" }
      assert_equal "Justificado", hielo[12]

      resumen = book.sheet("Resumen")
      executed = (1..resumen.last_row).map { |r| resumen.row(r) }.find { |row| row[0] == "Ejecutado" }
      assert_equal 1620.0, executed[1]
    end
  end

  test "nobody outside finances gets the report" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get expenses_reports_path
    assert_redirected_to dashboard_path
    get expenses_workbook_reports_path
    assert_redirected_to dashboard_path
  end

  private
    def present(concept, cents, category: nil, currency: "NIO", rate: 1)
      Expense.create!(concept: concept, estimated_cents: cents, currency: currency, exchange_rate: rate,
                      expense_category: category, presented_by: @finance, presented_by_name: @finance.full_name)
    end
end
