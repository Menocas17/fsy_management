module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :can_view_companies?, :full_company_access?, :can_edit_auxiliar_company?, :can_edit_company?,
                  :can_edit_company_staffing?, :can_edit_auxiliar_company_staffing?, :company_edit_level,
                  :auxiliar_company_edit_level,
                  :can_manage_staff?, :can_manage_alerts?, :can_manage_agenda?, :can_assign_to?,
                  :can_edit_participant?, :can_create_participants?, :can_delete_participant?, :can_edit_full_profile?,
                  :can_view_reports?, :can_view_participant_reports?, :can_view_logistics_reports?, :can_import_participants?,
                  :can_view_inventory?, :can_adjust_inventory?, :can_manage_inventories?, :can_check_in?, :can_manage_logistics_areas?,
                  :can_view_finances?, :can_operate_finances?, :can_configure_finances?,
                  :can_manage_accounts?, :can_create_account_for?, :can_reset_account_of?,
                  :can_view_night_attendance?, :night_attendance_gender_for, :can_open_night_attendance?,
                  :can_take_night_attendance?,
                  :can_view_infirmary?, :can_operate_infirmary?, :can_announce_infirmary?, :can_read_infirmary_notes?,
                  :can_cancel_infirmary_visit?
  end

  # Todo el mundo ve el sistema completo; quién edita qué se decide ficha por ficha más abajo.
  def can_view_companies?
    Current.user.present?
  end

  # Acceso total: superadmin, el matrimonio director y los coordinadores.
  def full_company_access?
    Current.user&.full_access? || false
  end

  # Participantes ---------------------------------------------------------------
  # La cadena de mando: el director de logística manda sobre su comité, el registrador sobre los jóvenes,
  # el auxiliar sobre los jóvenes de su rama y el consejero sobre los de su compañía. Todos sobre su propia ficha.
  def can_edit_participant?(participant)
    return false if Current.user.nil? || participant.nil?
    return true if full_company_access?

    actor = Current.user.participant
    return false if actor.nil?
    return true if actor.id == participant.id

    case actor.rol.to_s
    when "director_logistica" then participant.logistica? || participant.director_logistica?
    when "registrador"        then participant.joven?
    when "auxiliar"           then participant.joven? && actor.auxiliar_scope[:companies].map(&:id).include?(participant.company_id)
    when "consejero"          then participant.joven? && actor.counselor_scope.map(&:id).include?(participant.company_id)
    else false
    end
  end

  # El registrador inscribe jóvenes y el director de logística a su comité; qué rol puede darles lo vuelve
  # a verificar can_edit_participant? sobre la ficha ya armada.
  def can_create_participants?
    return true if full_company_access?

    %w[registrador director_logistica].include?(Current.user&.participant&.rol.to_s)
  end

  def can_delete_participant?(participant)
    return false if Current.user.nil? || participant.nil?
    return true if full_company_access?

    actor = Current.user.participant
    (actor&.director_logistica? && (participant.logistica? || participant.director_logistica?)) || false
  end

  # Nombre, rol, compañía y demás datos de identidad; el resto solo toca contacto, salud y logística del joven.
  def can_edit_full_profile?(participant)
    allowed_participant_attributes(participant).include?(:rol)
  end

  # Compañías -------------------------------------------------------------------
  # :full   → datos, rama y personal (acceso total)
  # :branch → datos y personal de las compañías de su rama, sin moverlas de rama (auxiliar)
  # :name   → solo el nombre que eligen los participantes (consejero)
  def company_edit_level(company)
    return :none if Current.user.nil? || company.nil?
    return :full if full_company_access?

    actor = Current.user.participant
    return :none if actor.nil?

    case actor.rol.to_s
    when "auxiliar"  then actor.auxiliar_scope[:companies].include?(company) ? :branch : :none
    when "consejero" then actor.counselor_scope.include?(company) ? :name : :none
    else :none
    end
  end

  def can_edit_company?(company)
    company_edit_level(company) != :none
  end

  def can_edit_company_staffing?(company)
    %i[full branch].include?(company_edit_level(company))
  end

  # El auxiliar solo renombra su propia compañía auxiliar; coordinadores y auxiliares los asigna quien tiene acceso total.
  def auxiliar_company_edit_level(auxiliar_company)
    return :none if Current.user.nil? || auxiliar_company.nil?
    return :full if full_company_access?

    actor = Current.user.participant
    actor&.auxiliar? && actor.auxiliar_companies.include?(auxiliar_company) ? :name : :none
  end

  def can_edit_auxiliar_company?(auxiliar_company)
    auxiliar_company_edit_level(auxiliar_company) != :none
  end

  def can_edit_auxiliar_company_staffing?(auxiliar_company)
    auxiliar_company_edit_level(auxiliar_company) == :full
  end

  def can_manage_staff?
    full_company_access?
  end

  # Cuentas ---------------------------------------------------------------------
  # El matrimonio director, los coordinadores, el director de logística y el superadmin crean la cuenta de
  # cualquier ficha y la restablecen (la persona elige otra con el enlace que le llega por correo). Restablecer
  # deja a alguien afuera hasta que abra ese correo, así que nadie lo hace sobre una cuenta con más poder que
  # la suya: la del director o un coordinador solo la toca el acceso total. La propia no se restablece: para
  # eso está «Cambiar contraseña».
  def can_manage_accounts?
    Current.user&.account_manager? || false
  end

  def can_create_account_for?(participant)
    participant.present? && participant.user.nil? && can_handle_account_of?(participant)
  end

  def can_reset_account_of?(participant)
    participant&.user.present? && participant.user != Current.user && can_handle_account_of?(participant)
  end

  # Áreas de logística -----------------------------------------------------------
  # El director de logística las arma (y decide quién registra, quién lleva las finanzas y quién
  # alimentación); el acceso total también.
  def can_manage_logistics_areas?
    Current.user&.logistics_areas_manager? || false
  end

  # Registro de llegadas ---------------------------------------------------------
  # Consultar una ficha escaneando la puede hacer cualquiera del staff; registrar la llegada, solo
  # el acceso total, el director de logística, los registradores y el comité de logística marcado para el
  # registro. Quien registra también anula (CheckinsController#void).
  def can_check_in?
    Current.user&.checkin_registrar? || false
  end

  # Asistencia nocturna -------------------------------------------------------
  def can_view_night_attendance?
    Current.user&.night_attendance_viewer? || false
  end

  # Qué lista de esta compañía le toca pasar a quien entra, o nil: el consejero, la de su género en su
  # compañía; el auxiliar, la de su género en las compañías de su rama (cuando falta el consejero).
  def night_attendance_gender_for(company)
    actor = Current.user&.participant
    return if actor.nil? || company.nil? || actor.gender.blank?

    in_reach = case actor.rol.to_s
    when "consejero" then actor.counselor_scope.include?(company)
    when "auxiliar"  then actor.auxiliar_scope[:companies].include?(company)
    else false
    end
    actor.gender if in_reach
  end

  def can_open_night_attendance?(company)
    can_view_night_attendance? || night_attendance_gender_for(company).present?
  end

  # Pasar una lista: la de su género, y solo la de esta noche. El superadmin, cualquiera, pero solo en la
  # noche de prueba (antes del evento).
  def can_take_night_attendance?(company, gender, night)
    return false unless night == NightAttendance.current_night
    return true if Current.user&.superadmin? && NightAttendance.testing?

    night_attendance_gender_for(company) == gender.to_s
  end

  # Enfermería ----------------------------------------------------------------
  # El tablero lo ve todo el staff. Ingresar, confirmar la entrada, dar de alta y escribir la ficha es de
  # enfermería (el área con la bandera nursing); el consejero o el auxiliar del joven solo avisan que lo llevan.
  def can_view_infirmary?
    Current.user&.infirmary_viewer? || false
  end

  def can_operate_infirmary?
    Current.user&.infirmary_operator? || false
  end

  def can_announce_infirmary?(joven)
    joven&.joven? && infirmary_care_team?(joven) || false
  end

  # Las notas clínicas son información médica de un menor: las leen enfermería, el matrimonio director y quienes
  # lo cuidan (sus consejeros y los auxiliares de su rama). El resto del staff ve quién está y por qué motivo.
  def can_read_infirmary_notes?(joven)
    return false if Current.user.nil? || joven.nil?
    return true if can_operate_infirmary? || Current.user.participant&.director?

    infirmary_care_team?(joven)
  end

  # Un aviso que todavía no llega se puede retirar: quien lo dio o enfermería.
  def can_cancel_infirmary_visit?(visit)
    return false unless visit&.en_camino?

    can_operate_infirmary? || (visit.announced_by_id.present? && visit.announced_by_id == Current.user&.participant_id)
  end

  # Si quien entra cuida a este joven: es consejero de su compañía o auxiliar de su rama. El tablero lo
  # pregunta por cada tarjeta, así que las compañías a su cargo se buscan una vez por página.
  def infirmary_care_team?(joven)
    return false if joven&.company_id.nil?

    @infirmary_care_company_ids ||= begin
      actor = Current.user&.participant
      case actor&.rol.to_s
      when "consejero" then actor.counselor_scope.map(&:id)
      when "auxiliar"  then actor.auxiliar_scope[:companies].map(&:id)
      else []
      end
    end
    @infirmary_care_company_ids.include?(joven.company_id)
  end
  private :infirmary_care_team?

  # Finanzas ------------------------------------------------------------------
  def can_view_finances?
    Current.user&.finance_viewer? || false
  end

  def can_operate_finances?
    Current.user&.finance_operator? || false
  end

  def can_configure_finances?
    Current.user&.finance_configurator? || false
  end

  def can_handle_account_of?(participant)
    return false unless can_manage_accounts?

    full_company_access? || !(participant.director? || participant.coordinador?)
  end
  private :can_handle_account_of?

  # Inventario ------------------------------------------------------------------
  # Cualquier miembro de logística ve y ajusta existencias; crear o borrar un inventario entero
  # queda para el acceso total y el director de logística.
  def can_view_inventory?
    Current.user&.inventory_member? || false
  end

  def can_adjust_inventory?
    can_view_inventory?
  end

  def can_manage_inventories?
    full_company_access? || Current.user&.participant&.director_logistica? || false
  end

  # Reportes -------------------------------------------------------------------
  # El acceso total imprime todo; el director de logística entra solo a lo suyo (inventario y gastos).
  def can_view_reports?
    Current.user&.reports_viewer? || false
  end

  def can_view_participant_reports?
    full_company_access?
  end

  def can_view_logistics_reports?
    full_company_access? || Current.user&.participant&.director_logistica? || false
  end

  def can_import_participants?
    full_company_access? || Current.user&.participant&.registrador? || false
  end

  def can_manage_alerts?
    Current.user&.alert_manager? || false
  end

  def can_manage_agenda?
    Current.user&.agenda_manager? || false
  end

  # Assignments follow the same chain of command as the companies: the director couple and the coordinators
  # reach everybody, an auxiliar reaches their branch, a consejero their own company, and the logistics
  # director their own team.
  def can_assign_to?(participant)
    return false if Current.user.nil? || participant.nil?
    return true if full_company_access?

    actor = Current.user.participant
    return false if actor.nil?

    case actor.rol.to_s
    when "director_logistica"
      participant.logistica? || participant.director_logistica?
    when "auxiliar"
      scope = actor.auxiliar_scope
      scope[:companies].map(&:id).include?(participant.company_id) || scope[:counselors].include?(participant)
    when "consejero"
      actor.counselor_scope.map(&:id).include?(participant.company_id)
    else
      false
    end
  end

  private
    # Contacto, salud y acomodación: lo que un líder necesita para cuidar a su gente.
    CARE_ATTRIBUTES = %i[avatar room shirt_number phone_number email_address emergency_contact_number
                         emergency_contact_name emergency_contact_relation allergies medicines diet
                         additional_medical_notes additional_instructions].freeze

    # Quién es la persona y dónde encaja en el evento.
    IDENTITY_ATTRIBUTES = %i[first_name last_name age m_person_in_charge h_person_in_charge identity_document
                             gender stake ward rol company_id logistics_area_id].freeze

    def require_finance_viewer!
      redirect_to dashboard_path, alert: "Finanzas es del área de Finanzas y la dirección" unless can_view_finances?
    end

    def require_finance_operator!
      redirect_to finances_path, alert: "Solo el área de Finanzas y el director de logística mueven gastos" unless can_operate_finances?
    end

    def require_finance_configurator!
      redirect_to finances_path, alert: "El presupuesto lo define el director de logística" unless can_configure_finances?
    end

    def require_infirmary_viewer!
      redirect_to dashboard_path, alert: "Enfermería es solo para el staff" unless can_view_infirmary?
    end

    def require_infirmary_operator!
      redirect_to infirmary_visits_path, alert: "Solo enfermería ingresa, da de alta y escribe la ficha clínica" unless can_operate_infirmary?
    end

    def require_logistics_areas_access!
      redirect_to dashboard_path, alert: "Las áreas de logística las administra el director de logística" unless can_manage_logistics_areas?
    end

    def require_checkin_access!
      unless can_check_in?
        redirect_to dashboard_path, alert: "El registro de llegadas es del comité de registro"
      end
    end

    def require_inventory_access!
      unless can_view_inventory?
        redirect_to dashboard_path, alert: "No estás autorizado para ver el inventario"
      end
    end

    def require_inventory_management!
      unless can_manage_inventories?
        redirect_to inventories_path, alert: "Solo la dirección de logística puede crear o cambiar inventarios"
      end
    end

    def require_reports_access!
      unless can_view_reports?
        redirect_to dashboard_path, alert: "No estás autorizado para ver los reportes"
      end
    end

    def require_logistics_reports!
      unless can_view_logistics_reports?
        redirect_to reports_path, alert: "No estás autorizado para ver este reporte"
      end
    end

    def require_participant_reports!
      unless can_view_participant_reports?
        redirect_to reports_path, alert: "No estás autorizado para ver este reporte"
      end
    end

    def require_participant_import!
      unless can_import_participants?
        redirect_to dashboard_path, alert: "No estás autorizado para cargar participantes"
      end
    end

    def require_participant_create!
      unless can_create_participants?
        redirect_to dashboard_path, alert: "No estás autorizado para registrar participantes"
      end
    end

    def require_participant_edit!
      unless can_edit_participant?(@participant)
        redirect_to participants_path, alert: "No estás autorizado para editar este registro"
      end
    end

    def require_participant_delete!
      unless can_delete_participant?(@participant)
        redirect_to participants_path, alert: "No estas autorizado para borrar registros"
      end
    end

    def require_agenda_manager!
      unless can_manage_agenda?
        redirect_to agenda_path, alert: "No estás autorizado para editar la agenda"
      end
    end

    def require_alert_manager!
      unless can_manage_alerts?
        redirect_to notifications_path, alert: "No estás autorizado para enviar alertas"
      end
    end

    def require_staff_manager!
      unless Current.user&.admin_or_staff_manager?
        redirect_to dashboard_path, alert: "Acceso no autorizado"
      end
    end

    def require_full_company_access!
      unless full_company_access?
        redirect_to companies_path, alert: "No estás autorizado para realizar esta acción"
      end
    end

    def require_company_edit!
      editable = if @auxiliar_company
        can_edit_auxiliar_company?(@auxiliar_company)
      else
        can_edit_company?(@company)
      end
      unless editable
        redirect_to(@auxiliar_company || @company || companies_path, alert: "No estás autorizado para editar esta compañía")
      end
    end

    # Asignar o quitar líderes es más que editar datos: el consejero no toca su propia plantilla.
    def require_company_staffing!
      staffing = if @auxiliar_company
        can_edit_auxiliar_company_staffing?(@auxiliar_company)
      else
        can_edit_company_staffing?(@company)
      end
      unless staffing
        redirect_to(@auxiliar_company || @company || companies_path, alert: "No estás autorizado para cambiar los líderes de esta compañía")
      end
    end

    # Qué campos puede tocar el actor en esta ficha; sobre cuáles fichas manda lo decide can_edit_participant?.
    def allowed_participant_attributes(target = nil)
      return [] if Current.user.nil?

      actor = Current.user.participant
      attributes = if full_company_access?
        CARE_ATTRIBUTES + IDENTITY_ATTRIBUTES
      else
        case actor&.rol.to_s
        when "registrador", "director_logistica" then CARE_ATTRIBUTES + IDENTITY_ATTRIBUTES
        when "auxiliar", "consejero"             then CARE_ATTRIBUTES
        else editing_self?(actor, target) ? CARE_ATTRIBUTES : []
        end
      end

      # Nadie se asciende a sí mismo: el rol, la compañía y el área las cambia quien tiene acceso total.
      attributes -= %i[rol company_id logistics_area_id] if editing_self?(actor, target) && !full_company_access?
      attributes
    end

    def editing_self?(actor, target)
      actor.present? && target.present? && actor.id == target.id
    end
end
