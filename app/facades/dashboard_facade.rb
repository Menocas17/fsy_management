class DashboardFacade
  def total_participants
    @total_participants ||= Participant.count
  end

  # Age and gender charts describe the jóvenes only; staff (directors, counselors…) are left out.
  def participants_by_age
    @participants_by_age ||= Participant.jovenes.data_by_age
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
    @male_count ||= Participant.jovenes.male_count
  end

  def female_count
    @female_count ||= Participant.jovenes.female_count
  end

  def shirt_count
    @shirt_count ||= Participant.shirt_count
  end
end
