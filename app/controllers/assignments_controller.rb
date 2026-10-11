# Delegar asignaciones desde la ficha (new/create/update/destroy, con can_assign_to?), confirmarlas quien las
# recibe (confirm) y seguir las delegadas (index): las propias o, con acceso total, todas.
class AssignmentsController < ApplicationController
  before_action :set_participant, only: %i[new create]
  before_action :set_assignment, only: %i[update destroy confirm]
  before_action :require_assign_permission!, except: %i[index confirm]
  before_action :require_delegator!, only: :index

  STATUS_FILTERS = { "pendiente" => "Pendientes", "confirmada" => "Confirmadas", "completada" => "Completadas" }.freeze

  def index
    @everyone = Current.user.full_access? && params[:de] != "mi"
    scope = @everyone ? Assignment.all : Assignment.delegated_by(Current.user.participant)
    @counts = scope.group(:status).count
    @status = params[:estado] if STATUS_FILTERS.key?(params[:estado])
    @assignments = (@status ? scope.where(status: @status) : scope)
                     .includes(:activity, participant: [ :company, Participant::AVATAR_PRELOAD ]).chronological
  end

  # Quien la recibe dice que la vio y la va a hacer; a quien la delegó le llega el aviso.
  def confirm
    unless @participant == Current.user.participant
      return redirect_back fallback_location: dashboard_path, alert: "Solo quien recibe la asignación la confirma."
    end

    if @assignment.status_pendiente?
      @assignment.confirm!
      Alert.announce_assignment_confirmed(@assignment)
      record_audit!(category: :asignaciones, action: "updated", target: @participant,
                    summary: "Confirmó la asignación «#{@assignment.display_title}»")
    end
    redirect_back fallback_location: myprofile_participants_path, notice: "Asignación confirmada."
  end

  def new
    @assignment = @participant.assignments.new(status: :pendiente)
  end

  def create
    @assignment = @participant.assignments.new(assignment_params)
    @assignment.assigned_by = Current.user&.participant
    @assignment.assigned_by_name = Current.user&.participant&.full_name || "Administrador del sistema"

    if @assignment.save
      Alert.announce_assignment(@assignment, user: Current.user)
      record_audit!(category: :asignaciones, action: "created", target: @participant,
                    summary: "Asignó «#{@assignment.display_title}» a #{@participant.full_name}")
      redirect_to participant_path(@participant), notice: "Asignación agregada. Se le avisó a #{@participant.first_name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @assignment.update(status: params.dig(:assignment, :status))
    redirect_back fallback_location: participant_path(@assignment.participant), notice: "Asignación marcada como #{@assignment.status_label.downcase}."
  end

  def destroy
    participant = @assignment.participant
    record_audit!(category: :asignaciones, action: "destroyed", target: participant,
                  summary: "Quitó «#{@assignment.display_title}» de #{participant.full_name}")
    @assignment.destroy

    redirect_back fallback_location: participant_path(participant), status: :see_other, notice: "Asignación eliminada."
  end

  private
    def set_participant
      @participant = Participant.find(params[:participant_id])
    end

    def set_assignment
      @assignment = Assignment.find(params[:id])
      @participant = @assignment.participant
    end

    def require_assign_permission!
      unless can_assign_to?(@participant)
        redirect_to participant_path(@participant), alert: "No estás autorizado para cambiar las asignaciones de esta persona"
      end
    end

    def require_delegator!
      redirect_to dashboard_path, alert: "No tienes asignaciones delegadas que seguir." unless Current.user.assignment_delegator?
    end

    def assignment_params
      params.expect(assignment: [ :activity_id, :title, :details, :starts_at, :location, :status ])
    end
end
