# Un cuarto del hotel. participants.room guarda su número: así lo leen la ficha, la compañía, el Conteo y los
# reportes, y un cuarto escrito a mano que no está en el hotel («L1») sigue funcionando.
class Room < ApplicationRecord
  belongs_to :hallway, touch: true

  # auto: lo usa el ordenamiento para jóvenes o consejeros. Los demás quedan apartados para su grupo; fuera_de_uso
  # no se usa.
  enum :purpose, { auto: 0, direccion: 1, logistica: 2, coordinacion: 3, fuera_de_uso: 4 }, prefix: true

  PURPOSE_LABELS = {
    "auto" => "Jóvenes o consejeros", "direccion" => "Matrimonio director", "logistica" => "Matrimonio de logística",
    "coordinacion" => "Coordinación y auxiliares", "fuera_de_uso" => "Fuera de uso"
  }.freeze
  DEFAULT_CAPACITY = 4
  MAX_CAPACITY = 12
  NUMBER_MAX = 12

  validates :number, presence: true, length: { maximum: NUMBER_MAX }, uniqueness: true
  validates :capacity, numericality: { only_integer: true, in: 1..MAX_CAPACITY }
  normalizes :number, with: ->(value) { value.to_s.strip }

  # Las fichas guardan el número: si el cuarto cambia de número, se van con él.
  after_update_commit -> { Participant.where(room: number_before_last_save).update_all(room: number, updated_at: Time.current) },
                      if: :saved_change_to_number?

  def purpose_label
    PURPOSE_LABELS.fetch(purpose)
  end

  def occupants
    Participant.where(room: number)
  end

  def to_param
    number
  end
end
