class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :participant, optional: true

  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :password_complexity

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Acceso total al evento: superadmin, el matrimonio director y los coordinadores.
  def full_access?
    return true if participant_id.nil?
    participant&.coordinador? || participant&.director? || false
  end

  # Paneles de gestión (historial, columnas de acciones): el acceso total más el director de logística,
  # que administra su propio comité. Un miembro raso de logística no administra a nadie.
  def admin_or_staff_manager?
    full_access? || participant&.director_logistica? || false
  end

  # Who may send alerts and edit the agenda: the director couple, the coordinators, the logistics director
  # and the superadmin.
  def alert_manager?
    return true if participant_id.nil?
    participant&.director? || participant&.coordinador? || participant&.director_logistica?
  end

  # The agenda is edited by the director couple, the coordinators and the superadmin.
  def agenda_manager?
    return true if participant_id.nil?
    participant&.director? || participant&.coordinador?
  end

  def unread_alerts_count
    Alert.visible_to(participant).unread_for(self).count
  end

  def full_name
    participant&.full_name || "Super Administrado"
  end

  def rol
    participant&.rol || "superadmin"
  end

  def role_label
    participant ? participant.role_label : "Superadmin"
  end

  private
  def password_complexity
    return if password.blank?

    unless password.match?(/\d/)
      errors.add :password, "debe incluir al menos un número."
    end

    unless password.match?(/[A-Z]/)
      errors.add :password, "debe incluir al menos una letra mayúscula."
    end

    unless password.match?(/[[:punct:]]/)
      errors.add :password, "debe incluir al menos un carácter especial."
    end
  end
end
