module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :can_view_companies?, :full_company_access?, :can_edit_auxiliar_company?, :can_edit_company?, :can_manage_staff?
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

  private
    def require_admin_to_create!
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
        allowed_attributes += [ :m_person_in_charge, :h_person_in_charge, :identity_document, :gender, :stake, :ward, :rol, :company_id ]
      end

      if user&.participant_id.nil?
        allowed_attributes = [
          :avatar, :room, :shirt_number, :phone_number, :email_address, :first_name, :last_name, :age,
          :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation,
          :allergies, :medicines, :diet, :additional_medical_notes, :additional_instructions,
          :m_person_in_charge, :h_person_in_charge,
          :identity_document, :gender, :stake, :ward, :rol, :company_id
        ]
      end

      allowed_attributes.uniq
    end
end
