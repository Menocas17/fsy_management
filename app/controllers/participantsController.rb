class ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[show edit update destroy send_password_reset]
  before_action :authorize_admin_to_delete!, only: [ :destroy ]
  before_action :require_admin_to_create!, only: [ :new, :create ]

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
       target_return = case params[:from]
       when "staff"
        staff_participants_path
       when "jovenes"
        participants_path
       else
        dashboard_path
       end

       if params[:from] == "myprofile"
         redirect_to myprofile_participants_path(from: params[:from]), notice: "Actualizado exitosamente."
       else
          redirect_to participant_path(@participant, from: params[:from], return_to: target_return), notice: "Actualizado exitosamente."
       end

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
    params.expect(participant: Participant.allowed_attributes_for(Current.user))
  end
end
