# One entry of the event agenda. Who it is for in detail (companies, ages) lives in the notes;
# audience/target_roles only decide who gets the automatic alert when the activity changes.
class Activity < ApplicationRecord
  CATEGORY_LABELS = {
    "devocional" => "Devocional", "comida" => "Comida", "clase" => "Clase o taller",
    "actividad" => "Actividad", "servicio" => "Servicio", "especial" => "Especial"
  }.freeze

  CATEGORY_STYLES = {
    "devocional" => { block: "bg-primary-500/15 border-primary-500 text-primary-700 dark:text-primary-300", dot: "bg-primary-500", pill: "bg-primary-500/15 text-primary-700 dark:text-primary-300" },
    "comida" => { block: "bg-cat-amber/20 border-cat-amber text-amber-700 dark:text-cat-amber", dot: "bg-cat-amber", pill: "bg-cat-amber/20 text-amber-700 dark:text-cat-amber" },
    "clase" => { block: "bg-cat-indigo/15 border-cat-indigo text-cat-indigo", dot: "bg-cat-indigo", pill: "bg-cat-indigo/15 text-cat-indigo" },
    "actividad" => { block: "bg-cat-green/15 border-cat-green text-green-700 dark:text-cat-green", dot: "bg-cat-green", pill: "bg-cat-green/15 text-green-700 dark:text-cat-green" },
    "servicio" => { block: "bg-cat-blue/15 border-cat-blue text-cat-blue", dot: "bg-cat-blue", pill: "bg-cat-blue/15 text-cat-blue" },
    "especial" => { block: "bg-cat-rose/15 border-cat-rose text-cat-rose", dot: "bg-cat-rose", pill: "bg-cat-rose/15 text-cat-rose" }
  }.freeze

  # Which role reads which note.
  ROLE_NOTES = {
    logistics_notes: { label: "Logística", roles: %w[logistica director_logistica], icon: "truck" },
    counselors_notes: { label: "Consejeros y auxiliares", roles: %w[consejero auxiliar], icon: "user-check" },
    youth_notes: { label: "Jóvenes", roles: %w[joven], icon: "users" }
  }.freeze

  has_many :activity_responsibles, dependent: :destroy
  has_many :responsibles, through: :activity_responsibles, source: :participant
  has_many :alerts, dependent: :nullify

  enum :category, { devocional: 0, comida: 1, clase: 2, actividad: 3, servicio: 4, especial: 5 }, prefix: true
  enum :audience, { todos: 0, por_roles: 1 }, prefix: true

  # The form splits the schedule into a date and two times.
  attr_accessor :date, :start_time, :end_time

  before_validation :compose_schedule

  validates :title, presence: true, length: { maximum: 120 }
  validates :starts_at, :ends_at, presence: true
  validate :ends_after_it_starts
  validate :within_the_event_days
  validate :roles_listed_for_role_activities

  def self.event_days
    Rails.configuration.x.event_start_on..Rails.configuration.x.event_end_on
  end

  scope :chronological, -> { order(:starts_at, :id) }
  scope :for_day, ->(day) { where(starts_at: day.all_day).chronological }
  scope :between, ->(first_day, last_day) { where(starts_at: first_day.beginning_of_day..last_day.end_of_day).chronological }

  def day
    starts_at.to_date
  end

  def duration_minutes
    ((ends_at - starts_at) / 60).round
  end

  def time_range
    "#{starts_at.strftime('%H:%M')} – #{ends_at.strftime('%H:%M')}"
  end

  # The audit log labels its target by #name.
  def name
    title
  end

  def category_label
    CATEGORY_LABELS.fetch(category, category)
  end

  def styles
    CATEGORY_STYLES.fetch(category, CATEGORY_STYLES["actividad"])
  end

  def audience_label
    return "Todos los participantes" if audience_todos?

    target_roles.map { |role| Participant.role_label(role) }.to_sentence(two_words_connector: " y ", last_word_connector: " y ")
  end

  def responsible_names
    responsibles.map(&:full_name).to_sentence(two_words_connector: " y ", last_word_connector: " y ")
  end

  # Managers read every note; everyone else reads the one written for their role.
  def notes_for(participant)
    ROLE_NOTES.filter_map do |field, meta|
      text = public_send(field)
      next if text.blank?
      next unless participant.nil? || meta[:roles].include?(participant.rol.to_s) || manager_role?(participant)

      meta.merge(text: text)
    end
  end

  def schedule_line
    "#{SpanishDates.long(starts_at.to_date)} · #{time_range}#{" · #{location}" if location.present?}"
  end

  private
    def manager_role?(participant)
      %w[director coordinador].include?(participant.rol.to_s)
    end

    def compose_schedule
      return if date.blank? || start_time.blank? || end_time.blank?

      self.starts_at = Time.zone.parse("#{date} #{start_time}")
      self.ends_at = Time.zone.parse("#{date} #{end_time}")
    end

    def ends_after_it_starts
      return if starts_at.blank? || ends_at.blank?

      errors.add(:ends_at, "debe ser posterior a la hora de inicio") if ends_at <= starts_at
    end

    # The agenda only covers the days of the event, so nothing can be scheduled outside them.
    def within_the_event_days
      return if starts_at.blank?
      return if self.class.event_days.cover?(starts_at.to_date)

      errors.add(:starts_at, "debe caer entre el #{SpanishDates.long(self.class.event_days.first)} y el #{SpanishDates.long(self.class.event_days.last)}")
    end

    def roles_listed_for_role_activities
      errors.add(:target_roles, "elige al menos un rol") if audience_por_roles? && target_roles.blank?
    end
end
