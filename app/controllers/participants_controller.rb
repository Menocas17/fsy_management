class ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[show edit update destroy send_password_reset]
  before_action :require_participant_delete!, only: [ :destroy ]
  before_action :require_participant_create!, only: %i[new create]
  before_action :require_participant_edit!, only: %i[edit update send_password_reset]

  def index
    @pagy, @participants = pagy(Participant.jovenes
                                           .includes(:company, :avatar_attachment, :avatar_blob)
                                           .search_by_name(params[:query])
                                           .by_stake(params[:stake])
                                           .by_ward(params[:ward])
                                           .by_gender(params[:gender])
                                           .by_company(params[:company])
                                           .by_care(params[:care])
                                           .order(:first_name, :last_name, :id))
  end

  def staff
    @pagy, @participants = pagy(Participant.staff
                                           .includes(:company, :avatar_attachment, :avatar_blob)
                                           .search_by_name(params[:query])
                                           .by_stake(params[:stake])
                                           .by_ward(params[:ward])
                                           .by_gender(params[:gender])
                                           .by_company(params[:company])
                                           .by_role(params[:rol])
                                           .order(:first_name, :last_name, :id))
  end

  def myprofile
    @participant = Current.user&.participant
  end

  def send_password_reset
    user = @participant.user

    if user

      PasswordsMailer.reset(user).deliver_later
      flash[:notice] = "Se ha enviado el enlace de recuperación a #{user.email_address}."
    else
      flash[:alert] = "Este participante no tiene una cuenta de usuario."
    end

    redirect_back fallback_location: dashboard_path
  end

  def show
  end

  def new
    @participant = Participant.new
  end

  def create
    @participant = Participant.new(participant_params)
    # El registrador inscribe jóvenes y el director de logística a su comité: nadie registra fuera de su alcance.
    return redirect_to(participants_path, alert: "No estás autorizado para registrar este tipo de participante") unless can_edit_participant?(@participant)

    if @participant.save
      record_audit!(category: :asignaciones, action: "created", target: @participant, summary: "Registró a #{@participant.full_name}")
      redirect_to @participant
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @participant.assign_attributes(participant_params)
    # Un cambio no puede sacar la ficha del alcance de quien lo hace (cambiarle el rol para escalar, por ejemplo).
    return redirect_to(participant_path(@participant), alert: "No estás autorizado para realizar este cambio") unless can_edit_participant?(@participant)

    if @participant.save
      audit_participant_update
      if params[:from] == "myprofile"
        redirect_to myprofile_participants_path(from: params[:from]), notice: "Actualizado exitosamente."
      else
        target_return = case params[:from]
        when "staff" then staff_participants_path
        when "jovenes" then participants_path
        else dashboard_path
        end
        redirect_to participant_path(@participant, from: params[:from], return_to: target_return), notice: "Actualizado exitosamente."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @participant.destroy
    record_audit!(category: :asignaciones, action: "destroyed", target: @participant, summary: "Eliminó el registro de #{@participant.full_name}")
    redirect_to participants_path, status: :see_other, notice: "El registro fue borrado exitosamente"
  end

  private
  FIELD_LABELS = {
    "first_name" => "nombre", "last_name" => "apellido", "age" => "edad", "rol" => "rol", "stake" => "estaca",
    "ward" => "barrio", "gender" => "género", "shirt_number" => "talla", "identity_document" => "identificación",
    "room" => "cuarto", "company_id" => "compañía", "contact_info" => "contacto", "medical_info" => "información médica",
    "person_in_charge" => "consejeros", "additional_instructions" => "notas", "logistics_area_id" => "área de logística"
  }.freeze

  def audit_participant_update
    fields = changed_field_labels(@participant, FIELD_LABELS)
    fields << "foto" if params.dig(:participant, :avatar).present?
    return if fields.empty?

    record_audit!(category: :asignaciones, action: "updated", target: @participant,
                  summary: "Actualizó #{spanish_list(fields)} de #{@participant.full_name}")
  end

  def set_participant
    @participant = Participant.find(params[:id])
  end

  def participant_params
    params.expect(participant: allowed_participant_attributes(@participant))
  end
end
