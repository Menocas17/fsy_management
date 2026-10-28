# El reparto de jóvenes en compañías (CompanyPlanner): show arma una propuesta sin guardar nada (?modo=todos para
# rehacerlo entero en ?companias= compañías, ?semilla= para «Reordenar») y create la aplica a las fichas.
class CompanyPlansController < ApplicationController
  before_action :require_full_company_access!
  before_action :set_options

  def show
    @plan = CompanyPlanner.new(mode: @mode, seed: @seed, companies: @company_count).call
    @fingerprint = CompanyPlanner.fingerprint
    @pending_count = Participant.joven.where(company_id: nil).count
  end

  def create
    # Si entre la vista previa y el clic cambió un joven, una compañía o un consejero, la misma semilla ya no da la
    # misma propuesta: se vuelve a mostrar en vez de aplicar algo que nadie vio.
    if params[:huella] != CompanyPlanner.fingerprint
      return redirect_to company_plan_path(plan_options), alert: "Algo cambió mientras veías la propuesta. Esta es la nueva: revísala antes de aplicarla."
    end

    plan = CompanyPlanner.new(mode: @mode, seed: @seed, companies: @company_count).call
    created = plan.new_companies.size
    changed = plan.apply!
    summary = if @mode == "todos"
      "Rehízo el reparto de jóvenes en #{helpers.pluralize(plan.buckets.size, "compañía")}" \
        "#{" (#{helpers.pluralize(created, "nueva", plural: "nuevas")})" if created.positive?}: #{helpers.pluralize(changed, "joven cambió", plural: "jóvenes cambiaron")} de compañía"
    else
      "Repartió #{helpers.pluralize(changed, "joven sin compañía", plural: "jóvenes sin compañía")} en las compañías"
    end
    record_audit!(category: :companias, action: "updated", target: nil, summary: summary)
    redirect_to companies_path, status: :see_other,
                notice: changed.zero? ? "Las compañías ya estaban así." : "Listo: #{helpers.pluralize(changed, "joven quedó", plural: "jóvenes quedaron")} en su compañía."
  end

  private
    def set_options
      @mode = CompanyPlanner::MODES.include?(params[:modo]) ? params[:modo] : "pendientes"
      @seed = params[:semilla].presence&.to_i
      @company_count = (params[:companias].to_i.clamp(1, 200) if @mode == "todos" && params[:companias].present?)
    end

    def plan_options
      { modo: (@mode if @mode == "todos"), companias: @company_count, semilla: @seed }.compact
    end
    helper_method :plan_options
end
