# Lo que el director de logística fija para todo el evento: el presupuesto general y el tipo de cambio.
module FinanceSettings
  BUDGET_KEY = "finance_budget_cents"
  RATE_KEY = "finance_usd_rate"

  module_function

  def budget_cents
    AppSetting[BUDGET_KEY].presence&.to_i
  end

  def budget_cents=(cents)
    AppSetting[BUDGET_KEY] = cents&.to_s
  end

  # Córdobas por dólar. nil hasta que se fije (los gastos en dólares la piden antes de presentarse).
  def usd_rate
    AppSetting[RATE_KEY].presence&.to_d
  end

  def usd_rate=(rate)
    AppSetting[RATE_KEY] = rate&.to_s
  end
end
