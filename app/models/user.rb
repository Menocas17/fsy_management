class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  has_many :alert_dismissals, dependent: :delete_all
  belongs_to :participant, optional: true

  # Cuánto vale el enlace con el que alguien elige su contraseña: al crearle la cuenta o al restablecerla.
  INVITATION_VALID_FOR = 7.days

  # El enlace deja de servir en cuanto se usa: el token depende de la contraseña actual.
  generates_token_for :invitation, expires_in: INVITATION_VALID_FOR do
    password_salt&.last(10)
  end

  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :password_complexity
  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :participant_id, uniqueness: true, allow_nil: true
  validates :email_address, confirmation: { case_sensitive: false }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # superadmin? (la columna) marca la cuenta del sistema: la única que abre o cierra los registros a mano.
  # Antes era «la cuenta sin participante», y borrar una ficha volvía superadmin a su cuenta.

  # Una cuenta sirve si es la del sistema o si sigue atada a una ficha; una que perdió su ficha no entra.
  def linked?
    superadmin? || participant_id.present?
  end

  # Crea la cuenta de una ficha con una contraseña aleatoria que nadie conoce: la persona elige la suya con el
  # enlace que le llega por correo (PasswordsMailer.invitation). Quien la crea escribe el correo dos veces.
  def self.create_for_participant(participant, email:, email_confirmation:)
    create(participant: participant, email_address: email, email_address_confirmation: email_confirmation.to_s.strip,
           password: random_password)
  end

  # Restablecer desde la ficha: la contraseña vieja deja de servir, se cierran sus sesiones y la persona
  # elige otra con un enlace nuevo. Nadie más llega a saberla.
  def revoke_password!
    transaction do
      update!(password: self.class.random_password)
      sessions.destroy_all
    end
  end

  # «Ver como» del superadmin: la cuenta de la ficha o, si todavía no tiene, una de mentira que no se puede
  # guardar, con la que la app decide menú y permisos igual que para esa persona.
  def self.stand_in_for(participant)
    participant.user || new(participant: participant, email_address: "ver-como@fsy.invalid").tap(&:readonly!)
  end

  # La primera vez que entra queda anotada: es lo que dice en la ficha si la cuenta ya se usó.
  def signed_in!
    update_column(:first_signed_in_at, Time.current) if first_signed_in_at.nil?
  end

  def signed_in_before?
    first_signed_in_at.present?
  end

  def invitation_token
    generate_token_for(:invitation)
  end

  # Cumple las reglas de complejidad (número, mayúscula, signo) y nadie la ve nunca.
  def self.random_password
    "#{SecureRandom.base58(24)}A1!"
  end

  # Acceso total al evento: superadmin, el matrimonio director y los coordinadores. Entran a todo y editan todo,
  # salvo presentar o aprobar gastos (finance_operator?, expense_approver?); Accesos y «Ver como» son solo del
  # superadmin.
  def full_access?
    return true if superadmin?
    participant&.coordinador? || participant&.director? || false
  end

  # Modo simple (solo en el teléfono): barra inferior en vez del menú lateral y un inicio con las cifras de
  # cada rol. Encendido por defecto; cada quien lo apaga en Configuración. Los jóvenes todavía no lo tienen.
  def simple_mode?
    simple_mode && !participant&.joven?
  end

  # La búsqueda global ocupa el botón central de la barra inferior (en vez de «Mi QR») para quien ve todo
  # el evento: dirección, coordinadores y el director de logística.
  def global_searcher?
    full_access? || participant&.director_logistica? || false
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

  # Quién elige qué registro está activo en el escáner (Configuración): el acceso total y el director de logística.
  def scan_manager?
    full_access? || participant&.director_logistica? || false
  end

  # Quién registra llegadas: el acceso total, el director de logística y el comité de logística cuya área
  # está marcada para el registro (hoy, «Registro»).
  def checkin_registrar?
    return true if full_access? || participant&.director_logistica?

    checkin_member?
  end

  # Logística con la bandera Registro: registra llegadas e inscribe y corrige jóvenes (antes, el rol registrador).
  def checkin_member?
    participant&.logistica? && participant.logistics_area&.checkin? || false
  end

  # Finanzas (docs/finanzas.md). Presentan gastos y los consolidan quien está en el área de Finanzas y el
  # director de logística; los aprueban solo el superadmin, el matrimonio director y el director de logística,
  # nunca la misma persona en dos pasos seguidos. Coordinación solo ve.
  def finance_member?
    participant&.logistica? && participant.logistics_area&.finance? || false
  end

  # Alimentación: el módulo todavía no existe; esto dice quién tendrá acceso (áreas con la bandera food).
  def food_member?
    participant&.logistica? && participant.logistics_area&.food? || false
  end

  # Enfermería: el doctor y quien lo acompañe son de logística, en un área con la bandera nursing. Ellos (y el
  # acceso total) ingresan, dan de alta y escriben la ficha clínica; un consejero solo avisa que lleva a un joven.
  def nursing_member?
    participant&.logistica? && participant.logistics_area&.nursing? || false
  end

  def infirmary_operator?
    full_access? || nursing_member?
  end

  # El tablero de enfermería lo ve todo el staff; los jóvenes no.
  def infirmary_viewer?
    superadmin? || participant&.staff_member? || false
  end

  # Quién administra las áreas de logística (crearlas, sus banderas y sus miembros).
  def logistics_areas_manager?
    full_access? || participant&.director_logistica? || false
  end

  def finance_operator?
    finance_member? || participant&.director_logistica? || false
  end

  # Aprobar o rechazar un gasto o una justificación sin factura.
  def expense_approver?
    superadmin? || participant&.director? || participant&.director_logistica? || false
  end

  def finance_viewer?
    finance_operator? || expense_approver? || full_access?
  end

  # Presupuesto, categorías y tipo de cambio: el director de logística y el acceso total. Presentar y aprobar
  # gastos no: eso sigue siendo de finance_operator? y expense_approver?.
  def finance_configurator?
    full_access? || participant&.director_logistica? || false
  end

  # El inventario lo mueve logística entera, más el acceso total.
  def inventory_member?
    full_access? || participant&.logistica? || participant&.director_logistica? || false
  end

  # Quién entra al módulo de reportes: el acceso total y el director de logística (solo su sección).
  # El panel de la asistencia nocturna: dirección, coordinadores, auxiliares y el director de logística.
  # Pasarla es de los consejeros (y del auxiliar, si falta el consejero): Authorization#night_attendance_gender_for.
  def night_attendance_viewer?
    full_access? || participant&.auxiliar? || participant&.director_logistica? || false
  end

  def reports_viewer?
    full_access? || participant&.director_logistica? || false
  end

  def unread_alerts_count
    Alert.inbox_for(self).unread_for(self).count
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
