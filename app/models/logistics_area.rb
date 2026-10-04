# Un equipo dentro de Logística (Finanzas, Registro, Alimentación…). Sus miembros son participantes con rol
# "logistica" o "director_logistica". Las banderas dan permisos a todos sus miembros; un área sin banderas
# solo ve. Se administran en la pantalla Áreas (LogisticsAreasController).
class LogisticsArea < ApplicationRecord
  has_many :members, class_name: "Participant", dependent: :nullify
  # Los gastos guardan el área que los presentó: con gastos, el área no se borra (se renombra).
  has_many :expenses, dependent: :restrict_with_error

  FLAGS = {
    checkin: [ "Registro", "Escanea llegadas y capacitaciones, y anula registros." ],
    finance: [ "Finanzas", "Presenta y aprueba gastos." ],
    food: [ "Alimentación", "Acceso al módulo de alimentación (próximamente)." ],
    nursing: [ "Enfermería", "Ingresa y da de alta jóvenes en enfermería y escribe su ficha clínica." ]
  }.freeze

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  normalizes :name, with: ->(name) { name.squish }

  scope :alphabetical, -> { order(:name) }

  def flags
    FLAGS.keys.select { |flag| public_send(flag) }
  end
end
