class OrganigramaController < ApplicationController
  VIEWS = %w[todo companias logistica mi_compania].freeze

  def show
    @view = VIEWS.include?(params[:scope]) ? params[:scope] : "todo"
    @directors = Participant.director.includes(:avatar_attachment).order(:gender, :first_name)
    @jovenes_counts = Participant.jovenes.where.not(company_id: nil).group(:company_id).count

    if @view == "mi_compania"
      @my_companies = Company.where(id: my_company_ids)
                             .includes(counselors: :avatar_attachment,
                                       auxiliar_company: { coordinator: :avatar_attachment, second_coordinator: :avatar_attachment, auxiliars: :avatar_attachment })
                             .by_number
    else
      # Both branches hang from the director couple; the companias/logistica views show just one of them.
      @show_companies = @view != "logistica"
      @show_logistics = @view != "companias"
      load_company_branch if @show_companies
      load_logistics_branch if @show_logistics
    end
  end

  private
    def load_company_branch
      @coordinators = Participant.coordinador.includes(:avatar_attachment).order(:gender, :first_name)
      @auxiliar_companies = AuxiliarCompany.includes(auxiliars: :avatar_attachment, companies: { counselors: :avatar_attachment })
                                           .sort_by { |auxiliar_company| [ auxiliar_company.first_company_number || Float::INFINITY, auxiliar_company.name ] }
      @orphan_companies = Company.where(auxiliar_company_id: nil).includes(counselors: :avatar_attachment).by_number
    end

    def load_logistics_branch
      @logistics_directors = Participant.director_logistica.includes(:avatar_attachment).order(:gender, :first_name)
      @logistics = Participant.logistica.includes(:avatar_attachment, :logistics_area).order(:first_name, :last_name)
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
