# An alert shown in the app's bell. Global alerts reach everybody; role alerts reach the roles listed in
# target_roles. Only critical alerts may also go out by email, and only to people who have an account.
class Alert < ApplicationRecord
  belongs_to :sender, class_name: "Participant", optional: true
  belongs_to :activity, optional: true
  belongs_to :recipient, class_name: "Participant", optional: true

  has_many_attached :images

  enum :audience, { todos: 0, por_roles: 1, individual: 2 }, prefix: true
  enum :priority, { informativa: 0, importante: 1, critica: 2 }, prefix: true
  enum :source, { manual: 0, agenda: 1, asignacion: 2 }, prefix: true

  PRIORITY_LABELS = { "informativa" => "Informativa", "importante" => "Importante", "critica" => "Crítica" }.freeze
  PRIORITY_STYLES = {
    "informativa" => "bg-cat-blue/15 text-cat-blue",
    "importante" => "bg-cat-amber/20 text-amber-700 dark:text-cat-amber",
    "critica" => "bg-cat-rose/15 text-cat-rose"
  }.freeze

  validates :title, :body, :sender_name, presence: true
  validates :title, length: { maximum: 120 }
  validate :roles_listed_for_role_alerts
  validate :recipient_named_for_individual_alerts
  validate :email_only_for_critical

  # Every alert leaves its own trace in Historial, whether a person sent it or the agenda did.
  after_create :record_in_history

  scope :recent, -> { order(created_at: :desc, id: :desc) }

  # Superadmins (no participant) see every alert; everyone else sees the global ones, their roles' and their own.
  scope :visible_to, ->(participant) {
    next all if participant.nil?

    where(audience: :todos)
      .or(where("alerts.target_roles && ARRAY[?]::varchar[]", [ participant.rol.to_s ]))
      .or(where(recipient_id: participant.id))
  }

  # Everything is unread until the person opens the notifications page for the first time.
  scope :unread_for, ->(user) {
    user&.alerts_read_at ? where("alerts.created_at > ?", user.alerts_read_at) : all
  }

  # Every agenda change announces itself to whoever the activity is aimed at.
  ANNOUNCEMENTS = {
    created: [ "Nueva actividad: %s", :informativa ],
    updated: [ "Cambio en la agenda: %s", :importante ],
    cancelled: [ "Actividad cancelada: %s", :importante ]
  }.freeze

  # A new assignment only concerns the person who received it.
  def self.announce_assignment(assignment, user:)
    create!(
      title: "Nueva asignación: #{assignment.display_title}",
      body: [ assignment.when_label, assignment.place, assignment.details.presence ].compact_blank.join(" · ").presence || "Revisa tu perfil para ver el detalle.",
      audience: :individual,
      recipient: assignment.participant,
      priority: :informativa,
      source: :asignacion,
      activity: assignment.activity,
      sender: user&.participant,
      sender_name: user&.participant&.full_name || "Administrador del sistema"
    )
  end

  def self.announce(activity, action:, user:, detail: nil)
    template, priority = ANNOUNCEMENTS.fetch(action)

    create!(
      title: format(template, activity.title),
      body: [ activity.schedule_line, detail, activity.description.presence ].compact.join("\n"),
      audience: activity.audience,
      target_roles: activity.target_roles,
      priority: priority,
      source: :agenda,
      activity: (action == :cancelled ? nil : activity),
      sender: user&.participant,
      sender_name: user&.participant&.full_name || "Administrador del sistema"
    )
  end

  # The audit log labels its target by #name.
  def name
    title
  end

  def priority_label
    PRIORITY_LABELS.fetch(priority, priority)
  end

  def priority_styles
    PRIORITY_STYLES.fetch(priority, PRIORITY_STYLES["informativa"])
  end

  def audience_label
    return "Todos los participantes" if audience_todos?
    return recipient&.full_name.presence || "Una persona" if audience_individual?

    target_roles.map { |role| Participant.role_label(role) }.to_sentence(two_words_connector: " y ", last_word_connector: " y ")
  end

  # Only people with an account can be emailed.
  def email_recipients
    return User.none unless send_email? && priority_critica?
    return User.where.not(participant_id: nil) if audience_todos?
    return User.where(participant_id: recipient_id) if audience_individual?

    User.joins(:participant).where(participants: { rol: target_roles })
  end

  private
    def roles_listed_for_role_alerts
      errors.add(:target_roles, "elige al menos un rol") if audience_por_roles? && target_roles.blank?
    end

    def record_in_history
      AuditLog.create!(
        actor: sender,
        actor_name: sender_name,
        action: "created",
        category: :alertas,
        summary: "Envió la alerta «#{title}» a #{audience_individual? ? audience_label : audience_label.downcase}",
        target_type: self.class.name,
        target_id: id,
        target_name: title
      )
    end

    def recipient_named_for_individual_alerts
      errors.add(:recipient, "elige a quién va dirigida") if audience_individual? && recipient_id.blank?
    end

    def email_only_for_critical
      errors.add(:send_email, "solo las alertas críticas se envían por correo") if send_email? && !priority_critica?
    end
end
