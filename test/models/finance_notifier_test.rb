require "test_helper"

class FinanceNotifierTest < ActiveSupport::TestCase
  setup do
    area = LogisticsArea.create!(name: "Finanzas", finance: true)
    @finance = Participant.create!(first_name: "Fina", last_name: "Cuentas", age: 30, stake: "villa_flor", shirt_number: "m",
                                   gender: "M", rol: :logistica, logistics_area: area)
    @director = Participant.create!(first_name: "Dire", last_name: "Logística", age: 45, stake: "villa_flor", shirt_number: "l",
                                    gender: "H", rol: :director_logistica)
    FinanceSettings.budget_cents = 1_000_000
    @food = ExpenseCategory.create!(name: "Alimentación", budget_cents: 100_000)
    @expense = Expense.create!(concept: "Agua", estimated_cents: 50_000, expense_category: @food,
                               presented_by: @finance, presented_by_name: @finance.full_name)
  end

  def alerts_for(participant) = Alert.where(recipient: participant, source: :finanzas)

  test "a presented expense notifies whoever can approve it, never its presenter, and opens the expense" do
    FinanceNotifier.presented(@expense)

    assert_equal [ "Gasto por aprobar: Agua" ], alerts_for(@director).pluck(:title)
    assert_empty alerts_for(@finance)
    assert_equal "/finanzas/gastos/#{@expense.id}", alerts_for(@director).first.link_path
  end

  test "the presenter hears back when it is approved or rejected" do
    @expense.approve(@director)
    FinanceNotifier.approved(@expense)
    assert_includes alerts_for(@finance).pluck(:title), "Gasto aprobado: Agua"

    other = Expense.create!(concept: "Hielo", estimated_cents: 1000, presented_by: @finance, presented_by_name: "Fina")
    other.reject(@director, "Ya hay hielo")
    FinanceNotifier.rejected(other)
    rejected = alerts_for(@finance).find_by(title: "Gasto rechazado: Hielo")
    assert_match(/Ya hay hielo/, rejected.body)
    assert rejected.priority_importante?
  end

  test "crossing 80 % and 100 % of a budget is announced once each, to the finance team" do
    @expense.approve(@director)
    FinanceNotifier.approved(@expense)
    assert_empty Alert.where("title LIKE ?", "Alimentación:%"), "50 % says nothing yet"

    second = Expense.create!(concept: "Pan", estimated_cents: 35_000, expense_category: @food, presented_by: @finance, presented_by_name: "Fina")
    second.approve(@director)
    FinanceNotifier.approved(second)
    assert_equal 1, alerts_for(@director).where("title LIKE ?", "Alimentación: ya va en el 85 %%").count
    FinanceNotifier.check_budget(second)
    assert_equal 1, alerts_for(@director).where("title LIKE ?", "Alimentación: ya va%").count, "not repeated"

    third = Expense.create!(concept: "Fruta", estimated_cents: 30_000, expense_category: @food, presented_by: @finance, presented_by_name: "Fina")
    third.approve(@director)
    FinanceNotifier.approved(third)
    over = alerts_for(@finance).find_by("title LIKE ?", "Alimentación: presupuesto superado%")
    assert over.priority_critica?
    assert_equal "/finanzas", over.link_path
  end

  test "a justification goes to someone else, and its author hears the answer" do
    @expense.approve(@director)
    @expense.justify(@finance, text: "Sin factura", actual_cents: 50_000, spent_on: nil, payment_method: nil)
    FinanceNotifier.justified(@expense)
    assert_includes alerts_for(@director).pluck(:title), "Justificación por aprobar: Agua"

    @expense.reject_justification(@director, "Pide copia")
    FinanceNotifier.justification_rejected(@expense)
    assert_includes alerts_for(@finance).pluck(:title), "Justificación no aceptada: Agua"
  end
end
