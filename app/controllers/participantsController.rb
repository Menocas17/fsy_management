class ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[show edit update destroy]




  def index
    @participants = Participant.all
    @shirt_counts = Participant.group(:shirt_number).count
  end

  def show
  end

  def new
    @participant = Participant.new
  end

  def create
    @participant = Participant.new(participant_params)
    if @participant.save
      redirect_to @participant
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @participant.update(participant_params)
      redirect_to participant_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # //TODO - Create the destroy method
  def destroy
    @participant.destroy
    redirect_to participants_path, status: :see_other, notice: "El registro fue borrado exitosamente"
  end

  private
  def set_participant
    @participant = Participant.find(params[:id])
  end

  def participant_params
    params.expect(participant: %i[ first_name last_name rol avatar company room stake ward genre identity_document shirt_number phone_number email_address emergency_contact_number emergency_contact_name emergency_contact_relation medical_info allergies medicines diet additional_medical_notes additional_instructions])
  end
end
