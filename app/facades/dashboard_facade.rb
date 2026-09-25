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

  # Cocina y enfermería: lo que cada ficha trae y que, si no se suma aquí, hay que ir a buscar de a una.
  def special_care
    @special_care ||= {
      allergies: Participant.jovenes.with_medical_note(:allergies).count,
      diet: Participant.jovenes.with_medical_note(:diet).count,
      medicines: Participant.jovenes.with_medical_note(:medicines).count
    }
  end

  def jovenes_by_dining_hall
    @jovenes_by_dining_hall ||= Company.jovenes_by_dining_hall
  end

  # Lo que sigue en la agenda: durante el evento son las dos próximas del día.
  def next_activities(limit = 2)
    @next_activities ||= Activity.where(starts_at: Time.current..).order(:starts_at).limit(limit).to_a
  end
end
