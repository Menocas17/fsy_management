# An alert shown in the app's bell. Global alerts reach everybody; role alerts reach the roles listed in
# target_roles; «personas» alerts reach the few participants in recipient_ids (enfermería: a joven's carers). Only critical alerts may also go out by email, and only to people who have an account.
class Alert < ApplicationRecord
  belongs_to :sender, class_name: "Participant", optional: true
  belongs_to :activity, optional: true
  belongs_to :recipient, class_name: "Participant", optional: true

  has_many_attached :images
  has_many :dismissals, class_name: "AlertDismissal", dependent: :delete_all

  enum :audience, { todos: 0, por_roles: 1, individual: 2, personas: 3 }, prefix: true
  enum :priority, { informativa: 0, importante: 1, critica: 2 }, prefix: true
  enum :source, { manual: 0, agenda: 1, asignacion: 2, finanzas: 3, asistencia: 4, enfermeria: 5, novedades: 6, tutorial: 7 }, prefix: true

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
  validate :recipients_listed_for_people_alerts
  validate :email_only_for_critical

  # Every alert leaves its own trace in Historial, whether a person sent it or the agenda did.
  # (La de bienvenida del tutorial no: es solo de esa persona y no la envió nadie.)
  after_create :record_in_history, unless: :source_tutorial?
  # …suena en los dispositivos suscritos aunque la app esté cerrada…
  after_create_commit :push_to_devices
  # …y refresca la campanita de quien la tenga abierta ahora mismo.
  after_create_commit :refresh_open_bells

  scope :recent, -> { order(created_at: :desc, id: :desc) }
  # Las que alguien envió: sin la bienvenida del tutorial, que es de una sola persona y se borra al terminarlo.
  scope :sent, -> { where.not(source: :tutorial) }

  # Superadmins (no participant) see every alert; everyone else sees the global ones, their roles' and their own.
  scope :visible_to, ->(participant) {
    next sent if participant.nil?

    where(audience: :todos)
      .or(where("alerts.target_roles && ARRAY[?]::varchar[]", [ participant.rol.to_s ]))
      .or(where(recipient_id: participant.id))
      .or(where("alerts.recipient_ids @> ARRAY[?]::uuid[]", [ participant.id ]))
  }

  # What a person's bell shows: what they can see, minus what they deleted one by one or cleared all at once.
  scope :inbox_for, ->(user) {
    next none if user.nil?

    scope = visible_to(user.participant).where.not(id: AlertDismissal.where(user_id: user.id).select(:alert_id))
    user.alerts_cleared_at ? scope.where("alerts.created_at > ?", user.alerts_cleared_at) : scope
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
    return Participant.where(id: recipient_ids).map(&:full_name).sort.to_sentence(two_words_connector: " y ", last_word_connector: " y ") if audience_personas?

    target_roles.map { |role| Participant.role_label(role) }.to_sentence(two_words_connector: " y ", last_word_connector: " y ")
  end

  # A quién le suena el teléfono: el mismo alcance de la campanita, entre quienes tienen cuenta. Las alertas por
  # roles (la agenda, la asistencia nocturna) también le suenan a la cuenta sin ficha (el superadmin), que las ve
  # todas en su campanita; las de una o pocas personas, no: son de esas personas.
  def push_recipients
    return User.all if audience_todos?
    return everyone_addressed_and_the_superadmin if audience_por_roles?

    addressed_users
  end

  # Only people with an account can be emailed.
  def email_recipients
    return User.none unless send_email? && priority_critica?
    return User.where.not(participant_id: nil) if audience_todos?

    addressed_users
  end

  private
    # Las cuentas de las personas a quienes va dirigida (no aplica a las globales).
    def addressed_users
      return User.where(participant_id: recipient_id) if audience_individual?
      return User.where(participant_id: recipient_ids) if audience_personas?

      User.joins(:participant).where(participants: { rol: target_roles })
    end

    def everyone_addressed_and_the_superadmin
      User.where(id: addressed_users.select(:id)).or(User.where(participant_id: nil))
    end

    def roles_listed_for_role_alerts
      errors.add(:target_roles, "elige al menos un rol") if audience_por_roles? && target_roles.blank?
    end

    def record_in_history
      AuditLog.create!(
        actor: sender,
        actor_name: sender_name,
        action: "created",
        category: :alertas,
        summary: "Envió la alerta «#{title}» a #{audience_individual? || audience_personas? ? audience_label : audience_label.downcase}",
        target_type: self.class.name,
        target_id: id,
        target_name: title
      )
    end

    def push_to_devices
      PushNotificationJob.perform_later(id)
    end

    # Un solo aviso para todos los que tienen la app abierta (stream "alerts", shared/_alerts_signal), no una
    # campanita dibujada por persona: con cientos de cuentas eran cientos de trabajos que competían con las
    # páginas. Cada campanita abierta pregunta su número (alert_signal_controller) y suena si creció.
    def refresh_open_bells
      Turbo::StreamsChannel.broadcast_replace_later_to "alerts", target: "alerts_signal",
                                                       partial: "shared/alerts_signal", locals: { alert: self }
    end

    def recipient_named_for_individual_alerts
      errors.add(:recipient, "elige a quién va dirigida") if audience_individual? && recipient_id.blank?
    end

    def recipients_listed_for_people_alerts
      errors.add(:recipient_ids, "elige a quiénes va dirigida") if audience_personas? && recipient_ids.blank?
    end

    def email_only_for_critical
      errors.add(:send_email, "solo las alertas críticas se envían por correo") if send_email? && !priority_critica?
    end
end
