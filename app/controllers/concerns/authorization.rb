module Authorization
  extend ActiveSupport::Concern

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

    def allowed_participant_attributes
      allowed_attributes = []
      user = Current.user

      if user&.counselers_staff? || user&.admin_or_staff_manager?
        allowed_attributes += [ :avatar, :room, :shirt_number, :phone_number, :email_address, :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation, :allergies, :medicines, :diet, :additional_medical_notes, :additional_intructions ]
      end

      if user&.admin_or_staff_manager?
        allowed_attributes += [ :company, :m_person_in_charge, :h_person_in_charge, :identity_document, :genre, :stake, :ward, :rol ]
      end

      if user&.participant_id.nil?
        allowed_attributes = [
          :avatar, :room, :shirt_number, :phone_number, :email_address, :first_name, :last_name, :age,
          :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation,
          :allergies, :medicines, :diet, :additional_medical_notes, :additional_intructions,
          :company, :m_person_in_charge, :h_person_in_charge,
          :identity_document, :genre, :stake, :ward, :rol
        ]
      end

      allowed_attributes.uniq
    end
end
