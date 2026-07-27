class DashboardsController < ApplicationController
  def show
    @total_participants = Participant.count
    @participants_by_age = Participant.data_by_age
    @total_jovenes = Participant.jovenes_count
    @total_staff = Participant.staff_count
    @count_by_stake = Participant.stake_count
    @count_by_role = Participant.role_count
    @male_count = Participant.male_count
    @female_count = Participant.female_count
    @shirt_count = Participant.shirt_count
    @data_by_age = Participant.data_by_age
  end
end
