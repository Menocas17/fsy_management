# El panel de Finanzas y su configuración (presupuesto general, tipo de cambio y categorías).
class FinancesController < ApplicationController
  before_action :require_finance_viewer!
  before_action :require_finance_configurator!, only: %i[edit update]

  def show
    @summary = FinanceSummary.new
    @waiting = Expense.where(status: %i[presented justification_pending]).includes(:expense_category).order(:created_at)
    @missing_receipt = Expense.approved.includes(:expense_category).order(:approved_at)
  end

  def edit
    @categories = ExpenseCategory.by_name
  end

  def update
    budget = Money.parse(params[:budget])
    rate = params[:usd_rate].to_s.tr(",", ".").presence&.to_d

    if budget.nil? || budget <= 0 || (rate && rate <= 1)
      @categories = ExpenseCategory.by_name
      flash.now[:alert] = "Revisa los montos: el presupuesto debe ser mayor que cero y el tipo de cambio, mayor que 1."
      return render :edit, status: :unprocessable_entity
    end

    FinanceSettings.budget_cents = budget
    FinanceSettings.usd_rate = rate
    record_audit!(category: :finanzas, action: "updated", target: nil,
                  summary: "Fijó el presupuesto general en #{Money.format(budget)}#{" y el dólar a C$ #{rate}" if rate}")
    redirect_to finances_path, notice: "Presupuesto y tipo de cambio guardados."
  end
end
