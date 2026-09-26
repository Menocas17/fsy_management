class AssignmentsController < ApplicationController
  before_action :set_participant, only: %i[new create]
  before_action :set_assignment, only: %i[update destroy]
  before_action :require_assign_permission!

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

    def assignment_params
      params.expect(assignment: [ :activity_id, :title, :details, :starts_at, :location, :status ])
    end
end
