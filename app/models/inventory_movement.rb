# Cada entrada o salida del inventario. No se editan ni se borran: un error se corrige con el
# movimiento contrario, y así la existencia y el historial nunca se contradicen.
class InventoryMovement < ApplicationRecord
  belongs_to :inventory_item
  belongs_to :participant, optional: true

  enum :reason, { entrega: 0, compra: 1, devolucion: 2, perdida: 3, conteo: 4, inicial: 5 }
  enum :source, { manual: 0, escaneo: 1 }, prefix: true

  REASON_LABELS = {
    "entrega" => "Entrega a compañías", "compra" => "Compra / reposición", "devolucion" => "Devolución",
    "perdida" => "Pérdida o daño", "conteo" => "Conteo físico", "inicial" => "Inventario inicial"
  }.freeze

  validates :delta, numericality: { only_integer: true, other_than: 0 }
  validate :cannot_leave_negative_stock

  before_validation :stamp_participant_name
  after_create :update_item_quantity

  scope :recent, -> { order(created_at: :desc) }

  def reason_label
    REASON_LABELS.fetch(reason, reason.to_s.humanize)
  end

  def delta_label
    format("%+d", delta)
  end

  def adds?
    delta.positive?
  end

  private
    def stamp_participant_name
      self.participant_name = participant&.full_name || "Administrador del sistema" if participant_name.blank?
    end

    def cannot_leave_negative_stock
      return if inventory_item.nil? || delta.nil? || delta.positive?

      if inventory_item.quantity + delta < 0
        errors.add(:delta, "no podés restar más de lo que hay (#{inventory_item.quantity_label})")
      end
    end

    def update_item_quantity
      inventory_item.update_column(:quantity, inventory_item.movements.sum(:delta))
    end
end
