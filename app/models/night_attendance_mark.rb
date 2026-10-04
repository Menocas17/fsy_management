# Un joven en la asistencia nocturna de su compañía: presente, o ausente con su motivo.
class NightAttendanceMark < ApplicationRecord
  belongs_to :night_attendance
  belongs_to :participant

  enum :status, { presente: 0, ausente: 1 }
  enum :absence_reason, { enfermeria: 0, otro: 1 }

  REASON_LABELS = { "enfermeria" => "Enfermería", "otro" => "Otro" }.freeze

  validates :status, presence: true
  validates :participant_id, uniqueness: { scope: :night_attendance_id }
  validates :absence_reason, presence: { message: "elige el motivo de la ausencia" }, if: :ausente?
  validates :absence_detail, presence: { message: "escribe el motivo" }, if: -> { ausente? && otro? }
  validates :absence_detail, length: { maximum: 200 }

  # «Enfermería» u «Otro: se fue con sus papás».
  def reason_label
    return unless ausente?

    otro? ? absence_detail.to_s : REASON_LABELS.fetch(absence_reason.to_s, "Sin motivo")
  end
end
