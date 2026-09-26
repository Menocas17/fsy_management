class Membership < ApplicationRecord
  belongs_to :associable, polymorphic: true
  belongs_to :participant

  enum :role, { auxiliar: 0, consejero: 1, participant: 2 }

  before_validation :derive_from_participant
  validate :within_staffing_limit

  private
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
