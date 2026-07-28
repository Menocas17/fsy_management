class ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[show edit update destroy]




  def index
  @participants = Participant.jovenes
                               .search_by_name(params[:query])
                               .by_stake(params[:stake])
                               .by_ward(params[:ward])
                               .by_genre(params[:genre])
                               .by_company(params[:company])
  end

  def staff
    @participants = Participant.staff
                               .search_by_name(params[:query])
                               .by_stake(params[:stake])
                               .by_ward(params[:ward])
                               .by_genre(params[:genre])
                               .by_company(params[:company])
                               .by_role(params[:rol])
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
      redirect_to participant_path(@participant, from: params[:from]), notice: "Actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

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
