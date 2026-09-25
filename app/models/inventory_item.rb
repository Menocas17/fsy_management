class InventoryItem < ApplicationRecord
  belongs_to :inventory
  has_many :movements, -> { order(created_at: :desc) }, class_name: "InventoryMovement", dependent: :destroy

  validates :name, presence: true
  validates :unit, presence: true
  validates :minimum, :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  before_validation :assign_code, on: :create

  scope :by_name, -> { order(:name) }
  scope :search, ->(query) {
    next if query.blank?

    where("inventory_items.name ILIKE :q OR inventory_items.code ILIKE :q OR inventory_items.location ILIKE :q",
          q: "%#{sanitize_sql_like(query.to_s.strip)}%")
  }
  scope :low, -> { where("quantity <= minimum") }

  def out?
    quantity.zero?
  end

  def low?
    !out? && quantity <= minimum
  end

  def status
    return :out if out?
    return :low if low?

    :ok
  end

  STATUS_LABELS = { out: "agotado", low: "por agotarse", ok: "al día" }.freeze

  def status_label
    STATUS_LABELS.fetch(status)
  end

  def quantity_label
    "#{quantity} #{unit}"
  end

  # Un ajuste es siempre un movimiento: la existencia se recalcula desde el historial, nunca a mano.
  def adjust!(delta:, participant:, reason:, note: nil, source: :manual)
    movement = movements.create!(delta: delta, participant: participant, reason: reason, note: note, source: source)
    movement
  end

  def recalculate_quantity!
    update_column(:quantity, movements.sum(:delta).clamp(0, Float::INFINITY).to_i)
  end

  # Lo que codifica el QR pegado en la caja.
  def qr_payload
    code
  end

  # El código es el identificador en la URL: escanear lleva directo a /articulos/MAT-0042.
  def to_param
    code
  end

  def name_with_code
    "#{name} · #{code}"
  end

  private
    def assign_code
      return if code.present? || inventory.nil?

      last = InventoryItem.where(inventory: inventory).order(:code).last
      sequence = last&.code.to_s[/\d+\z/].to_i + 1
      self.code = format("%s-%04d", inventory.code_prefix, sequence)
    end
end
