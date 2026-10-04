# La asistencia nocturna: cada noche, ya en los cuartos, el consejero confirma quién de su compañía está listo
# para dormir. Una lista por compañía, noche y género (el consejero solo pasa la de su género; si falta, la
# pasa el auxiliar del mismo género de la rama). Se marca a mano: presente, o ausente con su motivo.
#
# La noche va de 6 pm a 6 am: pasar la lista a la 1 de la mañana cuenta para la noche anterior.
class NightAttendance < ApplicationRecord
  NIGHT_ENDS_AT = 6 # hora en que termina la noche (6 am)
  ALERT_HOUR = 22   # a partir de esta hora, quien falte se avisa (NightAttendanceNotifier)
  GENDER_LABELS = { "H" => "Hombres", "M" => "Mujeres" }.freeze

  belongs_to :company
  belongs_to :taken_by, class_name: "Participant", optional: true
  has_many :marks, class_name: "NightAttendanceMark", dependent: :delete_all, autosave: true

  enum :gender, { M: 0, H: 1 }

  validates :night_on, :taken_by_name, :confirmed_at, presence: true
  validates :gender, uniqueness: { scope: %i[company_id night_on] }

  after_commit -> { broadcast_refresh_later_to "night_attendance" }

  # 6 pm–6 am es una sola noche; de día, la que viene.
  def self.current_night(time = Time.current)
    (time - NIGHT_ENDS_AT.hours).to_date
  end

  # Las noches del evento: de la primera a la víspera del último día (ese día se van a casa).
  def self.event_nights
    config = Rails.configuration.x
    (config.event_start_on...config.event_end_on).to_a
  end

  def self.alert_time(night)
    night.in_time_zone.change(hour: ALERT_HOUR)
  end

  def self.past_alert_hour?(night, time = Time.current)
    time >= alert_time(night) && current_night(time) == night
  end

  def self.gender_label(gender)
    GENDER_LABELS.fetch(gender.to_s)
  end

  # A quién se le pasa lista: los jóvenes de la compañía de ese género.
  def self.expected(company, gender)
    company.participants.where(gender: gender).order(:first_name, :last_name)
  end

  # Cómo está la lista de una compañía y género esa noche, para el panel y los avisos:
  # :pendiente (nadie la pasó), :ausentes (alguien falta o quedó sin marcar) o :completa.
  def self.status_for(attendance, expected_ids)
    return :pendiente if attendance.nil?

    attendance.missing_ids(expected_ids).any? ? :ausentes : :completa
  end

  # Quiénes se avisan de una compañía: su auxiliar y su coordinador (la rama) y el matrimonio director.
  def self.watchers_for(company)
    branch = company.auxiliar_company
    ids = Participant.where(rol: :director).pluck(:id)
    if branch
      ids += branch.auxiliars.pluck(:id)
      ids += branch.coordinators.map(&:id)
    end
    Participant.where(id: ids.uniq)
  end

  # Guarda las marcas que mandó el formulario (participant_id => { status:, absence_reason:, absence_detail: }).
  # Todos los jóvenes de la lista deben quedar marcados; devuelve los que quedaron ausentes y antes no lo estaban.
  def record(entries, taken_by:)
    expected = self.class.expected(company, gender).to_a
    # Lo guardado, no lo que dejó en memoria un intento que no pasó la validación.
    previously_absent = marks.select { |m| m.persisted? && m.status_in_database == "ausente" }.map(&:participant_id)

    expected.each do |joven|
      entry = entries.to_h.with_indifferent_access[joven.id] || {}
      mark = marks.find { |m| m.participant_id == joven.id } || marks.build(participant: joven)
      mark.assign_attributes(status: entry[:status].presence, absence_reason: entry[:absence_reason].presence,
                             absence_detail: entry[:absence_detail].to_s.strip.presence)
      mark.absence_reason = mark.absence_detail = nil if mark.presente?
      mark.absence_detail = nil if mark.enfermeria?
    end

    self.taken_by = taken_by
    self.taken_by_name = taken_by&.full_name || "Administrador del sistema"
    self.confirmed_at = Time.current

    unmarked = marks.reject { |m| m.status.present? }
    if unmarked.any?
      errors.add(:base, "Falta marcar a #{unmarked.map { |m| m.participant.full_name }.to_sentence(two_words_connector: " y ", last_word_connector: " y ")}")
      return false
    end
    invalid = marks.reject(&:valid?)
    if invalid.any?
      invalid.each { |m| errors.add(:base, "#{m.participant.full_name}: #{m.errors.messages.values.flatten.first}") }
      return false
    end
    return false unless save

    marks.select(&:ausente?).map(&:participant_id) - previously_absent
  end

  # Los que no están: ausentes, o de la compañía pero sin marca (llegaron a la lista después de pasarla).
  def missing_ids(expected_ids)
    present = marks.select(&:presente?).map(&:participant_id)
    expected_ids - present
  end

  def mark_for(participant)
    marks.find { |mark| mark.participant_id == participant.id }
  end

  def gender_label
    self.class.gender_label(gender)
  end

  def label
    "#{company.name} (#{gender_label.downcase})"
  end
end
