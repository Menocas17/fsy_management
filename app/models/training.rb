# Una capacitación del staff previa al evento. La asistencia se marca escaneando el QR de cada ficha.
class Training < ApplicationRecord
  has_many :attendances, class_name: "TrainingAttendance", dependent: :destroy
  has_many :participants, through: :attendances

  # Ver ScanWindow: automático es solo el día de la capacitación.
  enum :scan_mode, { auto: 0, open: 1, closed: 2 }, prefix: :scan

  validates :name, presence: true
  validates :held_on, presence: true, uniqueness: { message: "ya hay una capacitación ese día" }

  scope :chronological, -> { order(:held_on) }
  scope :upcoming, -> { where(held_on: Date.current..).chronological }
  scope :past, -> { where(held_on: ...Date.current).order(held_on: :desc) }

  # Cómo se agrupa el staff al contar quién vino: es lo que se mira para saber a quién hay que llamar.
  ROLE_GROUPS = {
    "Consejeros" => %w[consejero],
    "Auxiliares" => %w[auxiliar],
    "Logística" => %w[logistica director_logistica],
    "Dirección y coordinación" => %w[director coordinador registrador]
  }.freeze

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

  # Hasta que termina el día no hay «faltas», solo gente que todavía no se marcó.
  def pending?
    !past?
  end

  # { "Consejeros" => { attended: 3, expected: 5 }, ... } sin los grupos que no tienen a nadie.
  def role_breakdown
    present = attendances.joins(:participant).group("participants.rol").count
    expected = self.class.expected.group(:rol).count

    ROLE_GROUPS.filter_map do |label, roles|
      total = roles.sum { |role| expected[role].to_i }
      next if total.zero?

      [ label, { attended: roles.sum { |role| present[role].to_i }, expected: total } ]
    end.to_h
  end

  def scan_window
    ScanWindow.for(self)
  end

  def attended?(participant)
    attendances.exists?(participant: participant)
  end

  def label
    "#{name} · #{SpanishDates.long(held_on)}"
  end

  alias_attribute :to_s, :name
end
