class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  belongs_to :participant, optional: true

  # La contraseña con la que nace una cuenta creada desde una ficha (o restablecida). Es conocida a propósito:
  # quien entra con ella no puede hacer nada más que cambiarla (must_change_password).
  DEFAULT_PASSWORD = ENV.fetch("DEFAULT_ACCOUNT_PASSWORD", "FsyManagua2026!").freeze

  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :password_complexity
  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :participant_id, uniqueness: true, allow_nil: true
  validates :email_address, confirmation: { case_sensitive: false }
  validate :password_not_default, unless: :must_change_password?

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # superadmin? (la columna) marca la cuenta del sistema: la única que abre o cierra los registros a mano.
  # Antes era «la cuenta sin participante», y borrar una ficha volvía superadmin a su cuenta.

  # Una cuenta sirve si es la del sistema o si sigue atada a una ficha; una que perdió su ficha no entra.
  def linked?
    superadmin? || participant_id.present?
  end

  # Crea la cuenta de una ficha con la contraseña predeterminada; quien la crea escribe el correo dos veces.
  def self.create_for_participant(participant, email:, email_confirmation:)
    create(participant: participant, email_address: email, email_address_confirmation: email_confirmation.to_s.strip,
           password: DEFAULT_PASSWORD, must_change_password: true)
  end

  # Sin correo para recuperarla, la coordinación la devuelve a la predeterminada y cierra sus sesiones.
  def reset_to_default_password!
    transaction do
      update!(password: DEFAULT_PASSWORD, must_change_password: true)
      sessions.destroy_all
    end
  end

  # Acceso total al evento: superadmin, el matrimonio director y los coordinadores.
  def full_access?
    return true if superadmin?
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
    return true if superadmin?
    participant&.director? || participant&.coordinador? || participant&.director_logistica?
  end

  # Quién crea cuentas y las restablece: el matrimonio director, los coordinadores, el director de logística
  # (que lleva el registro y da de alta a quien llega, sea del comité o no) y el superadmin.
  def account_manager?
    return true if superadmin?
    participant&.director? || participant&.coordinador? || participant&.director_logistica? || false
  end

  # The agenda is edited by the director couple, the coordinators and the superadmin.
  def agenda_manager?
    return true if superadmin?
    participant&.director? || participant&.coordinador?
  end

  # Quién registra llegadas: el acceso total, el director de logística y el comité de logística
  # cuya área está marcada para el registro (hoy, «Registro»).
  def checkin_registrar?
    return true if full_access? || participant&.director_logistica?

    participant&.logistica? && participant.logistics_area&.checkin? || false
  end

  # Finanzas (docs/finanzas.md). Presentan y aprueban gastos quien está en el área de Finanzas y el director
  # de logística, nunca la misma persona en dos pasos seguidos; dirección y coordinación solo ven.
  def finance_member?
    participant&.logistica? && participant.logistics_area&.finance? || false
  end

  def finance_operator?
    finance_member? || participant&.director_logistica? || false
  end

  def finance_viewer?
    finance_operator? || full_access?
  end

  # Presupuesto, categorías y tipo de cambio: solo el director de logística. El superadmin, como dirección
  # y coordinación, solo ve.
  def finance_configurator?
    participant&.director_logistica? || false
  end

  # El inventario lo mueve logística entera, más el acceso total.
  def inventory_member?
    full_access? || participant&.logistica? || participant&.director_logistica? || false
  end

  # Quién entra al módulo de reportes: el acceso total y el director de logística (solo su sección).
  def reports_viewer?
    full_access? || participant&.director_logistica? || false
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
  # Al cambiarla (fuera de crear o restablecer), la nueva no puede ser la predeterminada que todos conocen.
  def password_not_default
    errors.add(:password, "no puede ser la contraseña predeterminada.") if password.present? && password == DEFAULT_PASSWORD
  end

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
