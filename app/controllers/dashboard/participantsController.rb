class Dashboard::ParticipantsController < ApplicationController
  before_action :set_product, only: %i[show ]

  def index
    @participants = Participant.all
  end

  def show
  end

  private
  def set_product
    @participant = Participant.find(params[:id])
  end
end
