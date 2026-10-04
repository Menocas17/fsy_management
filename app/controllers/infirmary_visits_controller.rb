# Enfermería (ver InfirmaryVisit). El tablero en vivo (index) lo ve todo el staff. Ingresar, confirmar la
# entrada y dar de alta es de enfermería; el consejero o el auxiliar del joven solo avisan que lo llevan
# (new/create), y ese aviso lo pueden retirar mientras no llega (destroy).
class InfirmaryVisitsController < ApplicationController
  PERIODS = { "hoy" => "Hoy", "todas" => "Todas" }.freeze

  before_action :require_infirmary_viewer!
  before_action :require_infirmary_operator!, only: %i[admit discharge]
  before_action :require_admitting_access!, only: %i[new create]
  before_action :set_visit, only: %i[admit discharge destroy]

  def index
    preload = [ :company, Participant::AVATAR_PRELOAD ]
    @inside = InfirmaryVisit.adentro.includes(participant: preload).order(:admitted_at).to_a
    @arriving = InfirmaryVisit.en_camino.includes(participant: preload).order(:announced_at).to_a
    @period = PERIODS.key?(params[:periodo]) ? params[:periodo] : "hoy"
    @discharged = InfirmaryVisit.alta.includes(participant: preload).order(discharged_at: :desc)
    @discharged = @discharged.where(discharged_at: Time.zone.today.all_day) if @period == "hoy"
    @attended_today = InfirmaryVisit.admitted_on(Time.zone.today).count
    @attended_total = InfirmaryVisit.where.not(admitted_at: nil).count
  end

  def new
    if params[:code].present?
      joven = reachable_jovenes.find_by_badge(params[:code])
      return redirect_to new_infirmary_visit_path(participant_id: joven.id) if joven

      flash.now[:alert] = "Ese gafete no es de ningún joven que puedas llevar a enfermería."
    end

    @participant = reachable_jovenes.find_by(id: params[:participant_id]) if params[:participant_id].present?
    if @participant
      @visit = InfirmaryVisit.new(participant: @participant)
      @ongoing = @participant.infirmary_visits.ongoing.first
    else
      @query = params[:q].to_s.strip
      @results = @query.present? ? reachable_jovenes.search_full_name(@query).includes(:company).order(:first_name, :last_name).limit(20) : []
    end
  end

  def create
    @participant = reachable_jovenes.find_by(id: params[:participant_id])
    return redirect_to new_infirmary_visit_path, alert: "No puedes llevar a ese joven a enfermería" if @participant.nil?

    actor = Current.user.participant
    reason, detail = visit_params.values_at(:reason, :reason_detail)
    @visit = if can_operate_infirmary?
      InfirmaryVisit.admit_directly(@participant, by: actor, reason: reason, detail: detail)
    else
      InfirmaryVisit.announce(@participant, by: actor, reason: reason, detail: detail)
    end

    if @visit.start
      name = @participant.full_name
      if @visit.adentro?
        record_audit!(category: :enfermeria, action: "created", target: @participant, summary: "Ingresó a #{name} a enfermería (#{@visit.reason_label.downcase})")
        notice = @visit.care_team.any? ? "#{name} quedó en enfermería. Se avisó a sus consejeros y auxiliares." : "#{name} quedó en enfermería."
      else
        record_audit!(category: :enfermeria, action: "created", target: @participant, summary: "Avisó que lleva a #{name} a enfermería (#{@visit.reason_label.downcase})")
        notice = "Enfermería ya sabe que llevas a #{name}. Le confirman la entrada al llegar."
      end
      redirect_to infirmary_chart_path(@participant), notice: notice
    else
      @ongoing = @participant.infirmary_visits.ongoing.first
      render :new, status: :unprocessable_entity
    end
  end

  # Enfermería confirma que llegó el joven del aviso: ahí sale el aviso a sus consejeros.
  def admit
    return redirect_to infirmary_chart_path(@visit.participant), alert: "Esa visita ya no está en camino" unless @visit.en_camino?

    @visit.admit!(by: Current.user.participant)
    record_audit!(category: :enfermeria, action: "updated", target: @visit.participant,
                  summary: "Confirmó la entrada de #{@visit.participant.full_name} a enfermería")
    redirect_back_or_to infirmary_chart_path(@visit.participant), notice: "Entrada confirmada. Se avisó a sus consejeros y auxiliares."
  end

  def discharge
    joven = @visit.participant
    return redirect_to infirmary_chart_path(joven), alert: "Esa visita no está abierta" unless @visit.adentro?

    if @visit.discharge(by: Current.user.participant, disposition: params[:disposition], notes: params[:discharge_notes])
      record_audit!(category: :enfermeria, action: "updated", target: joven,
                    summary: "Dio de alta a #{joven.full_name} de enfermería: #{@visit.disposition_label.downcase}")
      redirect_back_or_to infirmary_visits_path, notice: "#{joven.full_name} salió de enfermería."
    else
      redirect_back_or_to infirmary_chart_path(joven), alert: @visit.errors.full_messages.to_sentence
    end
  end

  def destroy
    joven = @visit.participant
    return redirect_to infirmary_chart_path(joven), alert: "Ese aviso ya no se puede retirar" unless can_cancel_infirmary_visit?(@visit)

    @visit.destroy!
    record_audit!(category: :enfermeria, action: "deleted", target: joven, summary: "Retiró el aviso de que llevaba a #{joven.full_name} a enfermería")
    redirect_to infirmary_visits_path, notice: "Aviso retirado."
  end

  private
    def set_visit
      @visit = InfirmaryVisit.find(params[:id])
    end

    def visit_params
      params.fetch(:infirmary_visit, {}).permit(:reason, :reason_detail)
    end

    # A quién puede ingresar (enfermería, a cualquier joven) o llevar (el consejero, a los de su compañía; el
    # auxiliar, a los de su rama).
    def reachable_jovenes
      return Participant.jovenes if can_operate_infirmary?

      actor = Current.user.participant
      company_ids = case actor&.rol.to_s
      when "consejero" then actor.counselor_scope.map(&:id)
      when "auxiliar"  then actor.auxiliar_scope[:companies].map(&:id)
      else []
      end
      Participant.jovenes.where(company_id: company_ids)
    end

    def require_admitting_access!
      return if can_operate_infirmary? || %w[consejero auxiliar].include?(Current.user.participant&.rol.to_s)

      redirect_to infirmary_visits_path, alert: "Ingresar a enfermería es de enfermería; los consejeros avisan que llevan a sus jóvenes"
    end
end
