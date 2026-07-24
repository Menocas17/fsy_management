class Dashboard::ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[show edit]

  def index
    @participants = Participant.all
  end

  def show
  end

  def edit
  end

  private
  def set_participant
    @participant = Participant.find(params[:id])
  end
end
