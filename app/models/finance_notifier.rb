# Los avisos de Finanzas (fase 3 de docs/finanzas.md): llegan a la campanita y como push, y abren el gasto.
#   - A quien aprueba: un gasto presentado o una justificación esperan su firma.
#   - A quien lo presentó o justificó: su gasto o su justificación fueron aprobados o rechazados.
#   - Al área de Finanzas y al director de logística: una categoría o el presupuesto general pasan del
#     80 % o del 100 %. Cada umbral se avisa una vez (y otra vez si se baja y se vuelve a pasar).
module FinanceNotifier
  THRESHOLDS = { warn: 80, over: 100 }.freeze

  module_function

  # Quienes mueven gastos: el área de Finanzas y el director de logística.
  def operators
    Participant.where(rol: :director_logistica)
               .or(Participant.where(rol: :logistica, logistics_area_id: LogisticsArea.where(finance: true).select(:id)))
  end

  # Quienes los aprueban: el matrimonio director y el director de logística (el superadmin los ve en su campanita).
  def approvers
    Participant.where(rol: %i[director director_logistica])
  end

  def presented(expense)
    notify(approvers.where.not(id: expense.presented_by_id), expense,
           "Gasto por aprobar: #{expense.concept}",
           "#{expense.presented_by_name} lo presentó por #{Money.format(expense.estimated_cents, expense.currency)}. Lo aprueba otra persona.")
  end

  def approved(expense)
    notify(Participant.where(id: expense.presented_by_id), expense, "Gasto aprobado: #{expense.concept}",
           "#{expense.approved_by_name} lo aprobó. Hecha la compra, consolídalo con la foto de la factura.")
    check_budget(expense)
  end

  def rejected(expense)
    notify(Participant.where(id: expense.presented_by_id), expense, "Gasto rechazado: #{expense.concept}",
           "#{expense.rejected_by_name}: «#{expense.rejection_reason}»", priority: :importante)
  end

  def justified(expense)
    notify(approvers.where.not(id: expense.justified_by_id), expense, "Justificación por aprobar: #{expense.concept}",
           "#{expense.justified_by_name} lo justificó sin factura: «#{expense.justification.to_s.truncate(90)}»")
  end

  def justification_approved(expense)
    notify(Participant.where(id: expense.justified_by_id), expense, "Justificación aceptada: #{expense.concept}",
           "#{expense.consolidated_by_name} la aceptó: el gasto quedó consolidado.")
    check_budget(expense)
  end

  def justification_rejected(expense)
    notify(Participant.where(id: expense.justified_by_id), expense, "Justificación no aceptada: #{expense.concept}",
           "«#{expense.justification_rejection}». Sube la factura o escribe otra justificación.", priority: :importante)
  end

  def consolidated(expense)
    check_budget(expense)
  end

  # Después de que cambia lo comprometido o lo ejecutado: la categoría del gasto y el presupuesto general.
  def check_budget(expense)
    summary = FinanceSummary.new
    rows = [ summary.total ]
    rows << summary.rows.find { |row| row.category&.id == expense.expense_category_id } if expense.expense_category_id
    rows.compact.select(&:budget).each { |row| check_row(row, expense) }
  end

  def check_row(row, expense)
    key = "finance_alert:#{row.category&.id || 'general'}"
    level = { over: 100, warn: 80 }.fetch(row.tone, 0)
    notified = AppSetting[key].to_i
    AppSetting[key] = level.to_s if level != notified
    return unless level > notified

    percent = (row.ratio * 100).round
    title = level == 100 ? "#{row.name}: presupuesto superado (#{percent} %)" : "#{row.name}: ya va en el #{percent} % del presupuesto"
    body = "Gastado #{Money.format(row.spent)} de #{Money.format(row.budget)} · disponible #{Money.format(row.available)}."
    notify(operators, expense, title, body, priority: level == 100 ? :critica : :importante, link: "/finanzas")
  end

  def notify(recipients, expense, title, body, priority: :informativa, link: nil)
    link ||= Rails.application.routes.url_helpers.expense_path(expense)
    recipients.distinct.each do |participant|
      Alert.create!(title: title.truncate(120), body: body, audience: :individual, recipient: participant,
                    priority: priority, source: :finanzas, sender_name: "Finanzas", link_path: link)
    end
  end
end
