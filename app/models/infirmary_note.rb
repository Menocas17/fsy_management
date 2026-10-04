# Una entrada de la ficha clínica de una visita: una nota de lo que se observó o un medicamento que se le dio
# (medication, con el medicamento y la dosis en el texto) y, si se tomaron, sus signos vitales. No se edita ni se borra (como los movimientos del inventario): un error se corrige con otra nota.
class InfirmaryNote < ApplicationRecord
  belongs_to :visit, class_name: "InfirmaryVisit", foreign_key: :infirmary_visit_id, touch: true
  belongs_to :author, class_name: "Participant", optional: true

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
  validates :body, presence: { message: "escribe qué medicamento y la dosis" }, if: :medication?
  validate :says_something

  before_validation :tidy_vitals

  def readonly?
    persisted?
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
end
