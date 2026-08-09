class DashboardFacade
  def total_participants
    @total_participants ||= Participant.count
  end

  def participants_by_age
    @participants_by_age ||= Participant.data_by_age
  end

  def total_jovenes
    @total_jovenes ||= Participant.jovenes_count
  end

  def total_staff
    @total_staff ||= Participant.staff_count
  end

  def count_by_stake
    @count_by_stake ||= Participant.stake_count
  end

  def count_by_role
    @count_by_role ||= Participant.role_count
  end

  def male_count
    @male_count ||= Participant.male_count
  end

  def female_count
    @female_count ||= Participant.female_count
  end

  def shirt_count
    @shirt_count ||= Participant.shirt_count
  end
end
