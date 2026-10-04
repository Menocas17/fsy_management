class OrganigramaController < ApplicationController
  VIEWS = %w[todo logistica mi_compania].freeze

  def show
    @view = VIEWS.include?(params[:scope]) ? params[:scope] : "todo"
    @directors = Participant.director.with_attached_avatar.order(:gender, :first_name)
    @jovenes_counts = Participant.jovenes.where.not(company_id: nil).group(:company_id).count

    if @view == "mi_compania"
      @my_companies = Company.where(id: my_company_ids)
                             .includes(counselors: Participant::AVATAR_PRELOAD,
                                       auxiliar_company: { coordinator: Participant::AVATAR_PRELOAD, second_coordinator: Participant::AVATAR_PRELOAD, auxiliars: Participant::AVATAR_PRELOAD })
                             .by_number
    else
      # Both branches hang from the director couple; the logistica view narrows to that branch.
      @show_companies = @view == "todo"
      @show_logistics = true
      load_company_branch if @show_companies
      load_logistics_branch if @show_logistics
    end
  end

  private
    def load_company_branch
      @coordinators = Participant.coordinador.with_attached_avatar.order(:gender, :first_name)
      @auxiliar_companies = AuxiliarCompany.includes(auxiliars: Participant::AVATAR_PRELOAD, companies: { counselors: Participant::AVATAR_PRELOAD })
                                           .sort_by { |auxiliar_company| [ auxiliar_company.first_company_number || Float::INFINITY, auxiliar_company.name ] }
      @orphan_companies = Company.where(auxiliar_company_id: nil).includes(counselors: Participant::AVATAR_PRELOAD).by_number
    end

    def load_logistics_branch
      @logistics_directors = Participant.director_logistica.with_attached_avatar.order(:gender, :first_name)
      @logistics = Participant.logistica.includes(:logistics_area).with_attached_avatar.order(:first_name, :last_name)
    end

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
