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

  # Hay motivos que solo tienen sentido en un sentido: nada «se entrega a las compañías» sumando,
  # ni «se compra» restando. El conteo físico sirve para los dos, que para eso se cuenta.
  REASON_DIRECTIONS = {
    "compra" => :in, "devolucion" => :in, "inicial" => :in,
    "entrega" => :out, "perdida" => :out,
    "conteo" => :both
  }.freeze

  # Los que se ofrecen al ajustar; «inicial» no, porque lo pone sola la creación del artículo.
  def self.reasons_for(direction)
    REASON_LABELS.except("inicial").select { |reason, _| [ direction.to_s, "both" ].include?(REASON_DIRECTIONS[reason].to_s) }
  end

  validates :delta, numericality: { only_integer: true, other_than: 0 }
  validate :cannot_leave_negative_stock
  validate :reason_matches_direction

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

    def reason_matches_direction
      return if delta.nil? || delta.zero? || reason.blank?

      allowed = REASON_DIRECTIONS[reason.to_s]
      return if allowed.nil? || allowed == :both
      return if (allowed == :in) == delta.positive?

      errors.add(:reason, "«#{reason_label}» no aplica para #{delta.positive? ? 'sumar' : 'restar'}")
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
