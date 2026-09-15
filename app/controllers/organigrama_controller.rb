class OrganigramaController < ApplicationController
  def show
    @mine = params[:scope] == "mi_compania"
    @directors = Participant.director.includes(:avatar_attachment).order(:gender, :first_name)
    @jovenes_counts = Participant.jovenes.where.not(company_id: nil).group(:company_id).count
    coordinators = { coordinator: :avatar_attachment, second_coordinator: :avatar_attachment }

    if @mine
      @my_companies = Company.where(id: my_company_ids)
                             .includes(counselors: :avatar_attachment, auxiliar_company: coordinators)
                             .by_number
    else
      @auxiliar_companies = AuxiliarCompany.includes(**coordinators, companies: { counselors: :avatar_attachment })
                                           .order(:name)
      @orphan_companies = Company.where(auxiliar_company_id: nil).includes(counselors: :avatar_attachment).by_number
      @logistics_directors = Participant.director_logistica.includes(:avatar_attachment).order(:gender, :first_name)
      @logistics = Participant.logistica.includes(:avatar_attachment, :logistics_area).order(:first_name, :last_name)
    end
  end

  private
    def my_company_ids
      participant = Current.user&.participant
      return [] unless participant

      case participant.rol
      when "joven"
        [ participant.company_id ].compact
      when "coordinador"
        Company.where(auxiliar_company_id: AuxiliarCompany.coordinated_by(participant).select(:id)).pluck(:id)
      when "consejero", "auxiliar"
        participant.companies.pluck(:id) +
          Company.where(auxiliar_company_id: participant.auxiliar_companies.select(:id)).pluck(:id)
      else
        []
      end
    end
end
