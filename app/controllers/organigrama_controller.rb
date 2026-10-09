class OrganigramaController < ApplicationController
  VIEWS = %w[todo logistica mi_compania].freeze

  def show
    @view = VIEWS.include?(params[:scope]) ? params[:scope] : "todo"

    if @view == "mi_compania"
      @directors = Participant.director.with_attached_avatar.order(:gender, :first_name)
      @jovenes_counts = Participant.jovenes.where.not(company_id: nil).group(:company_id).count
      @my_companies = Company.where(id: my_company_ids)
                             .includes(counselors: Participant::AVATAR_PRELOAD,
                                       auxiliar_company: { auxiliars: Participant::AVATAR_PRELOAD })
                             .by_number
    else
      # Todo el evento y la rama de logística son lo mismo para todos: van en caché con esta versión, y sus
      # datos se cargan solo si la caché no los tiene (OrganigramaHelper#load_general_organigrama).
      @organigrama_version = OrganigramaHelper.version
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
