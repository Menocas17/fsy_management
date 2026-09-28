require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  setup do
    area = LogisticsArea.create!(name: "Finanzas", finance: true)
    @finance = Participant.create!(first_name: "Fina", last_name: "Cuentas", age: 30, stake: "villa_flor", shirt_number: "m",
                                   gender: "M", rol: :logistica, logistics_area: area)
    @director = Participant.create!(first_name: "Dire", last_name: "Logística", age: 45, stake: "villa_flor", shirt_number: "l",
                                    gender: "H", rol: :director_logistica)
    @expense = Expense.create!(concept: "Agua", estimated_cents: 150_000, presented_by: @finance, presented_by_name: @finance.full_name)
  end

  test "whoever presents an expense cannot approve it, somebody else can" do
    refute @expense.approve(@finance)
    assert_match(/no puede aprobarlo/, @expense.errors.full_messages.to_sentence)
    assert @expense.reload.presented?

    assert @expense.approve(@director)
    assert @expense.reload.approved?
    assert_equal @director.full_name, @expense.approved_by_name
  end

  test "an approved expense is consolidated with its receipt and the real amount" do
    @expense.approve(@director)
    receipt = Rack::Test::UploadedFile.new(file_fixture("factura.png"), "image/png")

    assert @expense.consolidate(@finance, receipt: receipt, actual_cents: 142_000, spent_on: Date.current, payment_method: "efectivo")
    @expense.reload
    assert @expense.consolidated?
    assert @expense.receipt.attached?
    assert_equal 142_000, @expense.budget_cents
    refute @expense.without_receipt?
  end

  test "without a receipt, the justification has to be approved by someone else" do
    @expense.approve(@director)

    assert @expense.justify(@finance, text: "Vendedor ambulante", actual_cents: 150_000, spent_on: nil, payment_method: "efectivo")
    assert @expense.reload.justification_pending?

    refute @expense.approve_justification(@finance), "the one who wrote it cannot approve it"
    assert @expense.approve_justification(@director)
    assert @expense.reload.consolidated?
    assert @expense.without_receipt?
  end

  test "a rejected justification sends the expense back to wait for the receipt" do
    @expense.approve(@director)
    @expense.justify(@finance, text: "Se perdió", actual_cents: 150_000, spent_on: nil, payment_method: nil)

    refute @expense.reject_justification(@director, ""), "a reason is required"
    assert @expense.reject_justification(@director, "Pide copia al proveedor")
    assert @expense.reload.approved?
    assert_equal "Pide copia al proveedor", @expense.justification_rejection
  end

  test "consolidating needs the real amount and never skips a stage" do
    refute @expense.consolidate(@finance, receipt: nil, actual_cents: 1, spent_on: nil, payment_method: nil)
    @expense.approve(@director)
    receipt = Rack::Test::UploadedFile.new(file_fixture("factura.png"), "image/png")
    refute @expense.consolidate(@finance, receipt: receipt, actual_cents: nil, spent_on: nil, payment_method: nil)
    assert @expense.reload.approved?
  end

  test "dollars go to córdobas with the expense's exchange rate, and need one" do
    dollars = Expense.new(concept: "Proyector", currency: "USD", estimated_cents: 10_000, exchange_rate: 1,
                          presented_by: @finance, presented_by_name: @finance.full_name)
    refute dollars.valid?, "a dollar at 1 córdoba means the rate was never set"

    dollars.exchange_rate = 36.5
    assert dollars.save
    assert_equal 365_000, dollars.estimated_base_cents
  end

  test "the panel adds committed and executed against the general and category budgets" do
    FinanceSettings.budget_cents = 1_000_000
    food = ExpenseCategory.create!(name: "Alimentación", budget_cents: 200_000)
    @expense.update!(expense_category: food)
    @expense.approve(@director)
    Expense.create!(concept: "Papel", estimated_cents: 50_000, presented_by: @finance, presented_by_name: @finance.full_name)

    summary = FinanceSummary.new
    assert_equal 150_000, summary.total.committed
    assert_equal 50_000, summary.total.presented
    assert_equal 850_000, summary.total.available
    row = summary.rows.find { |r| r.name == "Alimentación" }
    assert_equal :ok, row.tone
    assert_equal 50_000, row.available
    assert summary.rows.any? { |r| r.name == "General" }, "expenses without a category show up as General"
  end
end
