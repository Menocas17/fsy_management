require "test_helper"

class FinancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    area = LogisticsArea.create!(name: "Finanzas", finance: true)
    @finance = Participant.create!(first_name: "Fina", last_name: "Cuentas", age: 30, stake: "villa_flor", shirt_number: "m",
                                   gender: "M", rol: :logistica, logistics_area: area)
    @director = Participant.create!(first_name: "Dire", last_name: "Logística", age: 45, stake: "villa_flor", shirt_number: "l",
                                    gender: "H", rol: :director_logistica)
    @coordinator = Participant.create!(first_name: "Coor", last_name: "Dinador", age: 40, stake: "villa_flor", shirt_number: "l",
                                       gender: "H", rol: :coordinador)
    @finance_user = User.create!(email_address: "fina@fsy.com", password: "Finanzas1!", participant: @finance)
    @director_user = User.create!(email_address: "dire@fsy.com", password: "Director1!", participant: @director)
    @coordinator_user = User.create!(email_address: "coor@fsy.com", password: "Coordina1!", participant: @coordinator)
    FinanceSettings.budget_cents = 500_000
  end

  test "an expense goes through its three stages, each by a different person" do
    sign_in_as(@finance_user)
    post expenses_path, params: { expense: { concept: "Agua", currency: "NIO", estimated_amount: "1,500.00" } }
    expense = Expense.last
    assert_redirected_to expense_path(expense)
    assert_equal 150_000, expense.estimated_cents

    get expense_path(expense)
    assert_select "[data-next-step='approve']", text: /lo tiene que aprobar otra persona/
    assert_select "form[action='#{approve_expense_path(expense)}']", 0, "the presenter gets no approve button"

    patch approve_expense_path(expense)
    assert expense.reload.presented?, "and the server refuses it too"
    assert Alert.exists?(recipient: @director, title: "Gasto por aprobar: Agua"), "the approver was told"

    sign_in_as(@director_user)
    patch approve_expense_path(expense)
    assert expense.reload.approved?

    sign_in_as(@finance_user)
    patch consolidate_expense_path(expense), params: {
      receipt: fixture_file_upload("factura.png", "image/png"), actual_amount: "1420", spent_on: Date.current, payment_method: "efectivo"
    }
    expense.reload
    assert expense.consolidated?
    assert_equal 142_000, expense.actual_cents
    assert_equal "finanzas", AuditLog.order(:created_at).last.category

    get expense_path(expense)
    assert_select "[data-receipt] img"
    assert_select "[data-timeline] li", 3
  end

  test "the superadmin only looks: no budget, no categories, no expenses" do
    sign_in_as(users(:one))

    get finances_path
    assert_response :success
    assert_select "a[href='#{edit_finances_path}']", 0
    assert_select "a[href='#{new_expense_path}']", 0

    patch finances_path, params: { budget: "1" }
    assert_equal 500_000, FinanceSettings.budget_cents
    assert_no_difference -> { ExpenseCategory.count } do
      post expense_categories_path, params: { expense_category: { name: "Pirata" } }
    end
    assert_no_difference -> { Expense.count } do
      post expenses_path, params: { expense: { concept: "Pirata", currency: "NIO", estimated_amount: "10" } }
    end
  end

  test "dirección and coordinación see finances but cannot move expenses or the budget" do
    sign_in_as(@coordinator_user)

    get finances_path
    assert_response :success
    assert_select "a[href='#{new_expense_path}']", 0
    assert_select "[data-finance-readonly]", text: /Solo lectura/

    assert_no_difference -> { Expense.count } do
      post expenses_path, params: { expense: { concept: "Pirata", currency: "NIO", estimated_amount: "10" } }
    end
    get edit_finances_path
    assert_redirected_to finances_path
  end

  test "someone outside finances does not even see the section" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    get finances_path
    assert_redirected_to dashboard_path
  end

  test "the logistics director sets the budget, the rate and categories with optional budgets" do
    sign_in_as(@director_user)

    patch finances_path, params: { budget: "250,000", usd_rate: "36.62" }
    assert_equal 25_000_000, FinanceSettings.budget_cents
    assert_equal BigDecimal("36.62"), FinanceSettings.usd_rate

    post expense_categories_path, params: { expense_category: { name: "Alimentación", budget: "80000", icon: "utensils", color: "orange" } }
    post expense_categories_path, params: { expense_category: { name: "Otros", budget: "", icon: "package", color: "slate" } }
    food = ExpenseCategory.find_by(name: "Alimentación")
    assert_equal [ 8_000_000, "utensils", "orange" ], [ food.budget_cents, food.icon, food.color ]
    assert_nil ExpenseCategory.find_by(name: "Otros").budget_cents

    get finances_path
    assert_select "[data-finance-total]", text: /C\$ 250,000.00/
  end

  test "without categories there is no «General» card: the general budget already says it" do
    Expense.create!(concept: "Agua", estimated_cents: 1000, presented_by: @finance, presented_by_name: "Fina")
    sign_in_as(@director_user)

    get finances_path
    assert_select "[data-finance-categories]", 0

    ExpenseCategory.create!(name: "Transporte", icon: "bus", color: "sky")
    get finances_path
    assert_select "[data-category-row='transporte'] .bg-sky-600"
    assert_select "[data-category-row='general']", 1, "with categories, the uncategorized ones show as General"
  end

  test "a category is edited on its own page with the icon and color picker" do
    category = ExpenseCategory.create!(name: "Transporte")
    sign_in_as(@director_user)

    get edit_expense_category_path(category)
    assert_select "input[type='radio'][name='expense_category[icon]']", Appearance::ICONS.size

    patch expense_category_path(category), params: { expense_category: { name: "Transporte", icon: "bus", color: "violet", budget: "5000" } }
    assert_equal [ "bus", "violet", 500_000 ], category.reload.values_at(:icon, :color, :budget_cents)
  end

  test "the finance member operates but does not set the budget" do
    sign_in_as(@finance_user)

    get finances_path
    assert_select "a[href='#{new_expense_path}']", text: /Nuevo gasto/
    assert_select "[data-finance-readonly]", 0

    patch finances_path, params: { budget: "1" }
    assert_redirected_to finances_path
    assert_equal 500_000, FinanceSettings.budget_cents
  end

  test "a category with expenses cannot be deleted" do
    category = ExpenseCategory.create!(name: "Transporte")
    Expense.create!(concept: "Bus", estimated_cents: 1000, expense_category: category, presented_by: @finance, presented_by_name: "Fina")
    sign_in_as(@director_user)

    assert_no_difference -> { ExpenseCategory.count } do
      delete expense_category_path(category)
    end
    assert_match(/ya tiene gastos/, flash[:alert])
  end

  test "every finance page renders, in córdobas and dollars" do
    FinanceSettings.usd_rate = 36.5
    ExpenseCategory.create!(name: "Alimentación", budget_cents: 100_000)
    dollars = Expense.create!(concept: "Proyector", currency: "USD", exchange_rate: 36.5, estimated_cents: 20_000,
                              presented_by: @finance, presented_by_name: "Fina")
    dollars.approve(@director)
    sign_in_as(@director_user)

    [ finances_path, edit_finances_path, expenses_path, expenses_path(etapa: "sin-factura"), new_expense_path, expense_path(dollars) ].each do |path|
      get path
      assert_response :success, path
    end
    assert_select "[data-next-step='consolidate'] input[name='exchange_rate'][value='36.5']"
    assert_includes response.body, "US$ 200.00 · C$ 7,300.00"
  end
end
