# Los gastos y sus tres etapas (docs/finanzas.md). El modelo decide si el paso vale (etapa y que no sea la
# misma persona del paso anterior); aquí solo se ve quién puede entrar y se deja constancia.
class ExpensesController < ApplicationController
  APPROVAL_STEPS = %i[approve reject approve_justification reject_justification].freeze

  before_action :require_finance_viewer!
  before_action :require_finance_operator!, except: [ :index, :show, *APPROVAL_STEPS ]
  before_action :require_expense_approver!, only: APPROVAL_STEPS
  before_action :set_expense, except: %i[index new create]

  FILTERS = {
    "espera" => %i[presented justification_pending], "sin-factura" => %i[approved],
    "consolidados" => %i[consolidated], "cerrados" => %i[rejected withdrawn]
  }.freeze

  def index
    @expenses = Expense.includes(:expense_category, :logistics_area, receipt_attachment: :blob).recent
    @expenses = @expenses.where(status: FILTERS[params[:etapa]]) if FILTERS.key?(params[:etapa])
    @expenses = @expenses.where(expense_category_id: params[:categoria].presence) if params.key?(:categoria) && params[:categoria] != ""
  end

  def show
  end

  def new
    @expense = Expense.new(currency: "NIO", planned_on: Date.current)
  end

  def create
    @expense = Expense.new(expense_params)
    participant = Current.user.participant
    @expense.presented_by = participant
    @expense.presented_by_name = participant&.full_name.to_s

    if @expense.save
      audit(@expense, "created", "Presentó el gasto «#{@expense.concept}» por #{Money.format(@expense.estimated_cents, @expense.currency)}")
      FinanceNotifier.presented(@expense)
      redirect_to @expense, notice: "Gasto presentado. Ahora lo tiene que aprobar otra persona."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Solo mientras está presentado y solo quien lo presentó.
  def edit
    redirect_to @expense, alert: "Solo se edita un gasto presentado, y solo quien lo presentó." unless editable?
  end

  def update
    return redirect_to(@expense, alert: "Ese gasto ya no se puede editar.") unless editable?

    if @expense.update(expense_params)
      audit(@expense, "updated", "Editó el gasto presentado «#{@expense.concept}»")
      redirect_to @expense, notice: "Gasto actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    run(@expense.approve(actor), "Aprobó el gasto «#{@expense.concept}»", "Gasto aprobado. Falta la factura para consolidarlo.", notify: :approved)
  end

  def reject
    run(@expense.reject(actor, params[:reason]), "Rechazó el gasto «#{@expense.concept}»", "Gasto rechazado.", notify: :rejected)
  end

  def withdraw
    run(@expense.withdraw(actor), "Retiró el gasto «#{@expense.concept}»", "Gasto retirado.")
  end

  def consolidate
    done = @expense.consolidate(actor, receipt: params[:receipt], actual_cents: Money.parse(params[:actual_amount]),
                                spent_on: params[:spent_on], payment_method: params[:payment_method],
                                exchange_rate: rate_param)
    run(done, "Consolidó el gasto «#{@expense.concept}» con su factura", "Gasto consolidado con su factura.", notify: :consolidated)
  end

  def justify
    done = @expense.justify(actor, text: params[:justification], actual_cents: Money.parse(params[:actual_amount]),
                            spent_on: params[:spent_on], payment_method: params[:payment_method],
                            exchange_rate: rate_param)
    run(done, "Justificó el gasto «#{@expense.concept}» sin factura", "Justificación enviada. La tiene que aprobar otra persona.", notify: :justified)
  end

  def approve_justification
    run(@expense.approve_justification(actor), "Aprobó la justificación del gasto «#{@expense.concept}»", "Justificación aprobada: gasto consolidado.",
        notify: :justification_approved)
  end

  def reject_justification
    run(@expense.reject_justification(actor, params[:reason]), "Rechazó la justificación del gasto «#{@expense.concept}»",
        "Justificación rechazada: el gasto sigue esperando la factura.", notify: :justification_rejected)
  end

  private
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # El superadmin no tiene ficha: aprueba firmando como «Administrador del sistema».
    def actor
      Current.user.participant || (Expense::SYSTEM_SIGNER if Current.user.superadmin?)
    end

    def editable?
      @expense.presented? && @expense.presented_by_id.present? && @expense.presented_by_id == actor&.id
    end

    def expense_params
      permitted = params.expect(expense: [ :concept, :vendor, :notes, :currency, :exchange_rate, :expense_category_id,
                                           :logistics_area_id, :planned_on, :estimated_amount ])
      permitted[:estimated_cents] = Money.parse(permitted.delete(:estimated_amount))
      permitted[:exchange_rate] = permitted[:exchange_rate].to_s.tr(",", ".").presence || (permitted[:currency] == "USD" ? default_rate : 1)
      permitted
    end

    def default_rate
      FinanceSettings.usd_rate || 1
    end

    def rate_param
      params[:exchange_rate].to_s.tr(",", ".").presence
    end

    # notify: el aviso de FinanceNotifier que corresponde al paso (a quien le toca el siguiente, o a quien lo pidió).
    def run(done, summary, notice, notify: nil)
      if done
        audit(@expense, "updated", summary)
        FinanceNotifier.public_send(notify, @expense) if notify
        redirect_to @expense, notice: notice
      else
        redirect_to @expense, alert: @expense.errors.full_messages.to_sentence
      end
    end

    def audit(expense, action, summary)
      record_audit!(category: :finanzas, action: action, target: expense, summary: summary)
    end
end
