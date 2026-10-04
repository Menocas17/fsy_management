# Una entrada de la ficha clínica de una visita: una nota de lo que se observó o un medicamento que se le dio
# (medication) y, si se tomaron, sus signos vitales. Lo que se da sale del inventario de enfermería: cada dosis es
# una salida de inventario atada a la nota (doses), y se descuenta al guardarla (save_with_doses). No se edita ni se borra (como los movimientos del inventario): un error se corrige con otra nota.
class InfirmaryNote < ApplicationRecord
  belongs_to :visit, class_name: "InfirmaryVisit", foreign_key: :infirmary_visit_id, touch: true
  belongs_to :author, class_name: "Participant", optional: true
  has_many :doses, -> { order(:created_at) }, class_name: "InventoryMovement", inverse_of: :infirmary_note

  # Cada signo con cómo se escribe en la ficha («38.4 °C», «FC 96»).
  VITALS = {
    "temperature" => { label: "Temperatura", unit: "°C", format: "%s °C" },
    "heart_rate" => { label: "Frecuencia cardiaca", unit: "lpm", format: "FC %s" },
    "blood_pressure" => { label: "Presión arterial", unit: "mmHg", format: "PA %s" },
    "oxygen" => { label: "Saturación", unit: "%", format: "SpO₂ %s %%" }
  }.freeze
  FEVER_FROM = 38.0

  store_accessor :vitals, *VITALS.keys

  validates :author_name, presence: true
  validates :body, length: { maximum: 2000 }
  validates :temperature, :heart_rate, :blood_pressure, :oxygen, length: { maximum: 12 }
  validate :says_something
  validate :medicine_named, if: :medication?
  validate :doses_in_stock, if: :medication?

  before_validation :tidy_vitals

  def readonly?
    persisted?
  end

  # Lo que se le dio, como llega del formulario: [{ item_id:, quantity: }]. Las filas sin artículo no cuentan y
  # el mismo artículo dos veces se suma. Solo aplica a un medicamento.
  def doses_to_give=(rows)
    pairs = Array(rows).filter_map do |row|
      row = row.to_h.with_indifferent_access
      [ row[:item_id].to_s, row[:quantity].to_s.strip ] if row[:item_id].present?
    end
    @doses_to_give = pairs.group_by(&:first).map { |id, same| [ id, same.sum { |_, quantity| quantity.to_i }, same.any? { |_, quantity| quantity !~ /\A\d+\z/ } ] }
  end

  # Los medicamentos elegidos con su artículo: [[item, cantidad]].
  def pending_doses
    return [] unless medication? && @doses_to_give.present?

    items = InventoryItem.medicines.where(id: @doses_to_give.map(&:first)).index_by { |item| item.id.to_s }
    @doses_to_give.filter_map { |id, quantity, _| [ items[id], quantity ] if items[id] }
  end

  # Guarda la nota y descuenta del inventario cada medicamento dado, todo o nada: si a uno no le alcanza la
  # existencia (otro lo acaba de dar), no se guarda la nota ni se descuenta ninguno.
  def save_with_doses(by:)
    return false unless valid?

    doses = pending_doses
    transaction do
      save!
      doses.each do |item, quantity|
        item.adjust!(delta: -quantity, participant: by, reason: :enfermeria, note: "Ficha de enfermería", infirmary_note: self)
      end
    end
    true
  rescue ActiveRecord::RecordInvalid => error
    errors.add(:base, error.record.is_a?(InventoryMovement) ? "#{error.record.inventory_item.name}: #{error.record.errors.messages.values.flatten.first}" : error.message)
    false
  end

  # «Acetaminofén 500 mg × 2 tabletas», por cada medicamento dado.
  def dose_labels
    doses.map { |dose| "#{dose.inventory_item.name} × #{-dose.delta} #{dose.inventory_item.unit}" }
  end

  # Los signos anotados, en el orden de VITALS: [["38.4 °C", true], ["FC 96", false]] (true = fiebre).
  def vital_readings
    VITALS.filter_map do |key, meta|
      value = vitals[key]
      [ format(meta[:format], value), key == "temperature" && value.to_s.tr(",", ".").to_f >= FEVER_FROM ] if value.present?
    end
  end

  private
    def tidy_vitals
      self.vitals = vitals.to_h.slice(*VITALS.keys).transform_values { |value| value.to_s.strip }.compact_blank
      self.body = body.to_s.strip.presence
    end

    def says_something
      return if body.present? || vitals.present? || medication?

      errors.add(:base, "escribe la nota o anota algún signo vital")
    end

    # Un medicamento dice cuál: elegido del inventario o, si no está en él, escrito en la nota.
    def medicine_named
      return if body.present? || @doses_to_give.present?

      errors.add(:base, "elige el medicamento que se le dio (o escríbelo si no está en el inventario)")
    end

    def doses_in_stock
      return if @doses_to_give.blank?

      found = pending_doses.to_h { |item, quantity| [ item.id.to_s, [ item, quantity ] ] }
      errors.add(:base, "ese medicamento no está en el inventario de enfermería") if found.size < @doses_to_give.size
      @doses_to_give.each do |id, quantity, malformed|
        item, = found[id]
        next if item.nil?

        if malformed || quantity < 1
          errors.add(:base, "#{item.name}: la cantidad debe ser un número entero mayor que cero")
        elsif quantity > item.quantity
          errors.add(:base, "#{item.name}: pides #{quantity} y en el inventario hay #{item.quantity}")
        end
      end
    end
end
