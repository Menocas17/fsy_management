# Una capacitación del staff previa al evento. La asistencia se marca escaneando el QR de cada ficha.
class Training < ApplicationRecord
  has_many :attendances, class_name: "TrainingAttendance", dependent: :destroy
  has_many :participants, through: :attendances

  validates :name, presence: true
  validates :held_on, presence: true, uniqueness: { message: "ya hay una capacitación ese día" }

  scope :chronological, -> { order(:held_on) }
  scope :upcoming, -> { where(held_on: Date.current..).chronological }
  scope :past, -> { where(held_on: ...Date.current).order(held_on: :desc) }

  # A quién se espera: la capacitación es del staff, no de los jóvenes.
  def self.expected
    Participant.staff
  end

  def expected_count
    @expected_count ||= self.class.expected.count
  end

  def attended_count
    @attended_count ||= attendances.count
  end

  def attendance_rate
    return 0 if expected_count.zero?

    (attended_count * 100.0 / expected_count).round
  end

  def today?
    held_on == Date.current
  end

  def past?
    held_on < Date.current
  end

  def days_away
    (held_on - Date.current).to_i
  end

  # Quién faltó: se calcula, no se guarda, así que agregar staff después no ensucia el historial.
  def absentees
    self.class.expected.where.not(id: attendances.select(:participant_id)).order(:first_name, :last_name)
  end

  def attended?(participant)
    attendances.exists?(participant: participant)
  end

  def label
    "#{name} · #{SpanishDates.long(held_on)}"
  end

  alias_attribute :to_s, :name
end
