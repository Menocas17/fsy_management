# A task given to one participant. It usually points at an agenda activity, which supplies the schedule
# and place; "otra" assignments carry their own title, time and location instead.
class Assignment < ApplicationRecord
  STATUS_LABELS = { "pendiente" => "Pendiente", "confirmada" => "Confirmada", "completada" => "Completada" }.freeze
  STATUS_STYLES = {
    "pendiente" => "bg-cat-amber/20 text-amber-700 dark:text-cat-amber",
    "confirmada" => "bg-cat-green/15 text-green-700 dark:text-cat-green",
    "completada" => "bg-canvas dark:bg-slate-700 text-ink-500 dark:text-slate-300"
  }.freeze

  belongs_to :participant
  belongs_to :activity, optional: true
  belongs_to :assigned_by, class_name: "Participant", optional: true

  enum :status, { pendiente: 0, confirmada: 1, completada: 2 }, prefix: true

  validates :assigned_by_name, presence: true
  validates :title, presence: { message: "escribe el nombre de la asignación" }, unless: :from_agenda?
  validates :title, length: { maximum: 120 }, allow_blank: true

  scope :chronological, -> {
    left_joins(:activity).order(Arel.sql("COALESCE(activities.starts_at, assignments.starts_at) ASC NULLS LAST")).order(:created_at)
  }

  def from_agenda?
    activity_id.present?
  end

  def display_title
    activity&.title.presence || title
  end

  def when_label
    if activity
      "#{SpanishDates.long(activity.day)} · #{activity.time_range}"
    elsif starts_at
      "#{SpanishDates.long(starts_at.to_date)} · #{starts_at.strftime('%H:%M')}"
    end
  end

  def place
    location.presence || activity&.location
  end

  def status_label
    STATUS_LABELS.fetch(status, status)
  end

  def status_styles
    STATUS_STYLES.fetch(status, STATUS_STYLES["pendiente"])
  end
end
