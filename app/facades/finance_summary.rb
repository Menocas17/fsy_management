# Los números del panel de Finanzas, todo en córdobas: por categoría y del evento completo.
#   comprometido = aprobados sin consolidar (por lo estimado)
#   ejecutado    = consolidados (por lo real)
#   disponible   = presupuesto − comprometido − ejecutado
class FinanceSummary
  Row = Struct.new(:category, :name, :budget, :committed, :executed, :presented, keyword_init: true) do
    def spent = committed + executed
    def available = budget && budget - spent
    def ratio = budget.to_i.positive? ? spent.fdiv(budget) : nil

    def tone
      return :none if ratio.nil?
      return :over if ratio > 1
      return :warn if ratio >= 0.8

      :ok
    end
  end

  def initialize
    @expenses = Expense.where(status: %i[presented approved justification_pending consolidated]).to_a
  end

  def total
    @total ||= build(nil, "Presupuesto general", FinanceSettings.budget_cents, @expenses)
  end

  # Cada categoría, más «General» si hay gastos sin categoría. Las que no tienen presupuesto propio
  # muestran lo gastado, sin barra.
  def rows
    @rows ||= begin
      by_category = @expenses.group_by(&:expense_category_id)
      categories = ExpenseCategory.by_name.map { |category| build(category, category.name, category.budget_cents, by_category[category.id] || []) }
      uncategorized = by_category[nil]
      uncategorized ? categories + [ build(nil, "General", nil, uncategorized) ] : categories
    end
  end

  # Suma de los presupuestos por categoría: si pasa del general, el panel lo avisa.
  def assigned_cents
    ExpenseCategory.sum(:budget_cents)
  end

  private
    def build(category, name, budget, expenses)
      Row.new(category: category, name: name, budget: budget,
              committed: expenses.select { |e| e.approved? || e.justification_pending? }.sum(&:estimated_base_cents),
              executed: expenses.select(&:consolidated?).sum(&:actual_base_cents),
              presented: expenses.select(&:presented?).sum(&:estimated_base_cents))
    end
end
