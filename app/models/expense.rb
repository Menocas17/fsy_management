# Un gasto del evento. Pasa por tres etapas, cada una dada por una persona distinta de la anterior:
#   presentado → aprobado → consolidado (con la factura, o con una justificación que otro aprueba).
# Ver docs/finanzas.md. Consolidado ya no cambia: un error se corrige con otro movimiento.
class Expense < ApplicationRecord
  belongs_to :expense_category, optional: true
  belongs_to :logistics_area, optional: true
  %i[presented_by approved_by rejected_by justified_by consolidated_by].each do |role|
    belongs_to role, class_name: "Participant", optional: true
  end
  has_one_attached :receipt

  enum :status, { presented: 0, approved: 1, rejected: 2, justification_pending: 3, consolidated: 4, withdrawn: 5 }
  enum :payment_method, { efectivo: 0, transferencia: 1, tarjeta: 2 }, prefix: :paid_with

  STATUS_LABELS = {
    "presented" => "Presentado", "approved" => "Aprobado · falta la factura", "rejected" => "Rechazado",
    "justification_pending" => "Justificación por aprobar", "consolidated" => "Consolidado", "withdrawn" => "Retirado"
  }.freeze
  PAYMENT_LABELS = { "efectivo" => "Efectivo", "transferencia" => "Transferencia", "tarjeta" => "Tarjeta" }.freeze
  RECEIPT_TYPES = %w[image/jpeg image/png image/heic image/heif image/webp application/pdf].freeze
  RECEIPT_MAX = 15.megabytes

  validates :concept, presence: true, length: { maximum: 120 }
  validates :presented_by_name, presence: true
  validates :currency, inclusion: { in: Money::CURRENCIES.keys }
  validates :estimated_cents, numericality: { greater_than: 0, only_integer: true }
  validates :actual_cents, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validates :exchange_rate, numericality: { greater_than: 0 }
  validates :exchange_rate, numericality: { greater_than: 1, message: "fija el tipo de cambio del dólar" }, if: :usd?
  validates :actual_cents, presence: { message: "debe ser el monto de la factura" }, if: -> { consolidated? || justification_pending? }
  validate :receipt_is_an_image_or_pdf

  scope :recent, -> { order(created_at: :desc) }
  # Lo que pesa sobre el presupuesto: aprobado (por lo estimado) y consolidado (por lo real).
  scope :committed, -> { where(status: %i[approved justification_pending]) }

  # El Historial nombra lo que se tocó.
  def name
    concept
  end

  def status_label
    STATUS_LABELS.fetch(status, status)
  end

  def category_name
    expense_category&.name || "General"
  end

  def usd?
    currency == "USD"
  end

  # A córdobas, la moneda base.
  def to_base(cents)
    cents && (usd? ? (cents * exchange_rate).round : cents)
  end

  def estimated_base_cents
    to_base(estimated_cents)
  end

  def actual_base_cents
    to_base(actual_cents)
  end

  # Cuánto le resta al presupuesto hoy.
  def budget_cents
    if consolidated? then actual_base_cents.to_i
    elsif approved? || justification_pending? then estimated_base_cents.to_i
    else 0
    end
  end

  def without_receipt?
    consolidated? && !receipt.attached?
  end

  # Pasos ------------------------------------------------------------------
  # Cada uno devuelve true o deja el motivo en errors. «by» es el Participant que actúa.

  def approve(by)
    step(by, from: :presented, not_by: presented_by_id, rule: "Quien presenta un gasto no puede aprobarlo.") do
      self.status = :approved
      stamp(:approved, by)
    end
  end

  def reject(by, reason)
    return fail_with("Escribe el motivo del rechazo.") if reason.blank?

    step(by, from: :presented, not_by: presented_by_id, rule: "Quien presenta un gasto no puede rechazarlo.") do
      self.status = :rejected
      self.rejection_reason = reason
      stamp(:rejected, by)
    end
  end

  def withdraw(by)
    return fail_with("Solo quien lo presentó puede retirarlo.") unless by&.id == presented_by_id

    step(by, from: :presented) { self.status = :withdrawn }
  end

  # Con la factura: el gasto queda consolidado por el monto real.
  def consolidate(by, receipt:, actual_cents:, spent_on:, payment_method:, exchange_rate: nil)
    return fail_with("Sube la foto de la factura.") if receipt.blank?

    step(by, from: :approved) do
      self.receipt = receipt
      record_purchase(actual_cents, spent_on, payment_method, exchange_rate)
      self.status = :consolidated
      stamp(:consolidated, by)
    end
  end

  # Sin factura: la justificación la tiene que aprobar otra persona para consolidar.
  def justify(by, text:, actual_cents:, spent_on:, payment_method:, exchange_rate: nil)
    return fail_with("Explica por qué no hay factura.") if text.blank?

    step(by, from: :approved) do
      record_purchase(actual_cents, spent_on, payment_method, exchange_rate)
      self.justification = text
      self.justification_rejection = nil
      self.status = :justification_pending
      stamp(:justified, by)
    end
  end

  def approve_justification(by)
    step(by, from: :justification_pending, not_by: justified_by_id,
             rule: "Quien escribe la justificación no puede aprobarla.") do
      self.status = :consolidated
      stamp(:consolidated, by)
    end
  end

  # Vuelve a «aprobado»: sigue faltando la factura (o una justificación mejor).
  def reject_justification(by, reason)
    return fail_with("Escribe por qué no se acepta la justificación.") if reason.blank?

    step(by, from: :justification_pending, not_by: justified_by_id,
             rule: "Quien escribe la justificación no puede rechazarla.") do
      self.status = :approved
      self.justification_rejection = reason
    end
  end

  private
    def step(by, from:, not_by: nil, rule: nil)
      return fail_with("Este paso lo da alguien con ficha de participante.") if by.nil?
      return fail_with("El gasto ya no está en esa etapa (#{status_label.downcase}).") unless status == from.to_s
      return fail_with(rule) if not_by && by.id == not_by

      yield
      save
    end

    def stamp(step, by)
      self["#{step}_by_id"] = by.id
      self["#{step}_by_name"] = by.full_name
      self["#{step}_at"] = Time.current
    end

    def record_purchase(actual_cents, spent_on, payment_method, exchange_rate)
      self.actual_cents = actual_cents
      self.spent_on = spent_on.presence || Date.current
      self.payment_method = payment_method.presence
      self.exchange_rate = exchange_rate if usd? && exchange_rate.present?
    end

    def fail_with(message)
      errors.add(:base, message)
      false
    end

    def receipt_is_an_image_or_pdf
      return unless receipt.attached?

      errors.add(:receipt, "debe ser una foto o un PDF") unless RECEIPT_TYPES.include?(receipt.blob.content_type)
      errors.add(:receipt, "pesa más de 15 MB") if receipt.blob.byte_size > RECEIPT_MAX
    end
end
