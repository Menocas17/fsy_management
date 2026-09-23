module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :can_view_companies?, :full_company_access?, :can_edit_auxiliar_company?, :can_edit_company?, :can_manage_staff?, :can_manage_alerts?, :can_manage_agenda?, :can_assign_to?
  end

  def can_view_companies?
    Current.user.present?
  end

  def full_company_access?
    user = Current.user
    return true if user&.participant_id.nil?
    user&.participant&.coordinador? || user&.participant&.director?
  end

  def can_edit_auxiliar_company?(ac)
    return false if Current.user.nil? || ac.nil?
    return true if full_company_access?

    participant = Current.user.participant
    return false if participant.nil?

    if participant.auxiliar?
      participant.auxiliar_companies.include?(ac)
    else
      false
    end
  end

  def can_edit_company?(company)
    return false if Current.user.nil? || company.nil?
    return true if full_company_access?

    participant = Current.user.participant
    return false if participant.nil?

    case participant.rol.to_s
    when "auxiliar"
      participant.auxiliar_scope[:companies].include?(company)
    when "consejero"
      participant.counselor_scope.include?(company)
    else
      false
    end
  end

  def can_manage_staff?
    full_company_access?
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
    def require_admin_to_create!
      unless Current.user&.admin_or_staff_manager?
        redirect_to dashboard_path, alert: "Acceso no autorizado"
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

    def require_full_company_access!
      unless full_company_access?
        redirect_to companies_path, alert: "No estás autorizado para realizar esta acción"
      end
    end

    def require_staff_manager!
      unless Current.user&.admin_or_staff_manager?
        redirect_to dashboard_path, alert: "Acceso no autorizado"
      end
    end

    def authorize_admin_to_delete!
      unless Current.user&.admin_or_staff_manager?
        redirect_to participants_path, alert: "No estas autorizado para borrar registros"
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

    def allowed_participant_attributes
      allowed_attributes = []
      user = Current.user

      if user&.counselers_staff? || user&.admin_or_staff_manager?
        allowed_attributes += [ :avatar, :room, :shirt_number, :phone_number, :email_address, :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation, :allergies, :medicines, :diet, :additional_medical_notes, :additional_instructions ]
      end

      if user&.admin_or_staff_manager?
        allowed_attributes += [ :m_person_in_charge, :h_person_in_charge, :identity_document, :gender, :stake, :ward, :rol, :company_id, :logistics_area_id ]
      end

      if user&.participant_id.nil?
        allowed_attributes = [
          :avatar, :room, :shirt_number, :phone_number, :email_address, :first_name, :last_name, :age,
          :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation,
          :allergies, :medicines, :diet, :additional_medical_notes, :additional_instructions,
          :m_person_in_charge, :h_person_in_charge,
          :identity_document, :gender, :stake, :ward, :rol, :company_id, :logistics_area_id
        ]
      end

      allowed_attributes.uniq
    end
end
