class Dashboard::ParticipantsController < ApplicationController
  def index
    @participants = Participant.all
  end
end
