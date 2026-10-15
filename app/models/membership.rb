class Membership < ApplicationRecord
  belongs_to :associable, polymorphic: true
  belongs_to :participant

  enum :role, { auxiliar: 0, consejero: 1, participant: 2 }

  before_validation :derive_from_participant
  validate :within_staffing_limit
  validate :gender_slot_free, :counselor_in_one_company

  # El otro lado de Participant#sync_counselor_membership: asignar o quitar al consejero desde la compañía
  # también cambia la «Compañía» de su ficha. update_all para no volver a disparar la sincronización.
  after_create_commit :place_counselor, if: :counselor_of_company?
  after_destroy_commit :unplace_counselor, if: :counselor_of_company?

  private
    def counselor_of_company?
      consejero? && associable_type == "Company"
    end

    def place_counselor
      Participant.where(id: participant_id).update_all(company_id: associable_id)
    end

    # Solo si sigue siendo consejero de esta compañía: si lo movieron o cambió de rol, su ficha ya dice dónde está.
    def unplace_counselor
      Participant.where(id: participant_id, rol: :consejero, company_id: associable_id).update_all(company_id: nil)
    end

    def within_staffing_limit
      return if participant? || associable.nil? || !formula_applies?

      current_count = Membership
        .where(associable_type: associable_type, associable_id: associable_id, role: role)
        .where.not(id: id)
        .count

      if current_count >= staffing_limit
        errors.add :base, "Esta compañía ya alcanzó su cupo de #{role} (#{staffing_limit})."
      end
    end

    # La base admite un hombre y una mujer por rol (índice único): sin esto, el segundo del mismo género pasaba el
    # cupo de 2 y explotaba al guardar (error 500).
    def gender_slot_free
      return if participant? || associable.nil? || gender.nil? || !formula_applies? || staffing_limit.infinite?

      taken = Membership.where(associable: associable, role: role, gender: gender).where.not(id: id)
      errors.add(:base, "Ya hay #{role} #{gender == Participant.genders["M"] ? "mujer" : "hombre"} en esta compañía.") if taken.exists?
    end

    # Un consejero es de una sola compañía (su ficha guarda una): nunca queda sentado en dos.
    def counselor_in_one_company
      return unless counselor_of_company? && participant_id

      elsewhere = Membership.where(associable_type: "Company", role: :consejero, participant_id: participant_id)
                            .where.not(associable_id: associable_id).where.not(id: id)
      errors.add(:base, "#{participant.full_name} ya es consejero de otra compañía.") if elsewhere.exists?
    end

    def formula_applies?
      !associable.is_a?(AuxiliarCompany) || role == "auxiliar"
    end

    def staffing_limit
      if associable.is_a?(AuxiliarCompany)
        role == "consejero" ? Float::INFINITY : 2
      else
        %w[consejero auxiliar].include?(role.to_s) ? 2 : Float::INFINITY
      end
    end

    def derive_from_participant
      self.gender = Participant.genders[participant.gender] if participant&.gender.present?
      self.role = participant_role(participant&.rol) if participant&.rol.present?
    end

    def participant_role(rol)
      case rol.to_s
      when "auxiliar"   then "auxiliar"
      when "consejero"  then "consejero"
      else "participant"
      end
    end
end
