class DashboardFacade
  # Las cifras de todo el evento son las mismas para quien abra el inicio: se guardan unos segundos en la caché
  # en vez de recalcularlas en cada visita (son la mitad de las consultas de la página, y el inicio es lo que más
  # se abre). Las tres cifras propias de cada rol (simple_kpis) no pasan por aquí: siempre van al día.
  GLOBAL_STATS_TTL = 30.seconds

  # En la memoria del proceso y no en Rails.cache: en producción esa caché es la base de datos, y cada cifra era
  # una ida y vuelta a Neon (nueve en el inicio). Cada proceso calcula las suyas una vez cada 30 s. Donde la caché
  # está apagada (pruebas) se respeta.
  def self.global_cache
    @global_cache ||= if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
      Rails.cache
    else
      ActiveSupport::Cache::MemoryStore.new(size: 4.megabytes)
    end
  end

  # user: quien abre el inicio; con él se arman sus tres cifras del modo simple (simple_kpis).
  def initialize(user: nil)
    @user = user
  end

  def total_participants
    @total_participants ||= global(:total_participants) { Participant.count }
  end

  # Las gráficas de edad, género y estaca describen solo a los jóvenes: el staff (que además puede venir de
  # una estaca que no participa) queda fuera.
  def participants_by_age
    @participants_by_age ||= global(:participants_by_age) { Participant.jovenes.data_by_age }
  end

  def total_jovenes
    @total_jovenes ||= global(:total_jovenes) { Participant.jovenes_count }
  end

  def total_staff
    @total_staff ||= global(:total_staff) { Participant.staff_count }
  end

  def count_by_stake
    @count_by_stake ||= global(:count_by_stake) { Participant.jovenes.stake_count }
  end

  def count_by_role
    @count_by_role ||= global(:count_by_role) { Participant.role_count }
  end

  def male_count
    @male_count ||= global(:male_count) { Participant.jovenes.male_count }
  end

  def female_count
    @female_count ||= global(:female_count) { Participant.jovenes.female_count }
  end

  def shirt_count
    @shirt_count ||= global(:shirt_count) { Participant.shirt_count }
  end

  # Cocina y enfermería: lo que cada ficha trae y que, si no se suma aquí, hay que ir a buscar de a una.
  def special_care
    @special_care ||= global(:special_care) do
      {
        medical_information: Participant.jovenes.with_medical_note(:medical_information).count,
        diet: Participant.jovenes.with_medical_note(:diet).count
      }
    end
  end

  def jovenes_by_dining_hall
    @jovenes_by_dining_hall ||= global(:jovenes_by_dining_hall) { Company.jovenes_by_dining_hall }
  end

  # Lo que sigue en la agenda: durante el evento son las dos próximas del día.
  def next_activities(limit = 2)
    @next_activities ||= Activity.where(starts_at: Time.current..).order(:starts_at).limit(limit).to_a
  end

  # Modo simple: las tres cifras del inicio de cada rol. Cada una es { label:, value:, sub:, badge:, icon:, tone:, link: };
  # badge es el momento de la cifra («Ahora», «Hoy»), que va en gris junto al icono;
  # link es la página que abre (DashboardHelper#simple_kpi_url), nil si no lleva a ninguna.
  def simple_kpis
    @simple_kpis ||= case @user&.participant&.rol
    when "consejero" then company_kpis(counselor_jovenes, "Mis jóvenes", :my_company)
    when "auxiliar" then company_kpis(auxiliar_jovenes, "Jóvenes a cargo", :my_company)
    when "coordinador" then company_kpis(Participant.jovenes, "Jóvenes", :participants)
    when "director_logistica" then logistics_director_kpis
    when "logistica" then logistics_kpis
    else direction_kpis
    end
  end

  private
    def global(name, &block)
      self.class.global_cache.fetch([ "dashboard-global", name ], expires_in: GLOBAL_STATS_TTL, &block)
    end

    def kpi(label, value, icon, tone, sub: nil, badge: nil, link: nil)
      { label: label, value: value, sub: sub, badge: badge, icon: icon, tone: tone, link: link }
    end

    def counselor_jovenes
      Participant.jovenes.where(company_id: @user.participant.counselor_scope.select(:id))
    end

    def auxiliar_jovenes
      Participant.jovenes.where(company_id: @user.participant.auxiliar_scope[:companies].map(&:id))
    end

    # Consejero, auxiliar y coordinación: sus jóvenes, cuántos están en enfermería y la última asistencia.
    def company_kpis(jovenes, label, link)
      present, night = night_attendance_present(jovenes)
      [
        kpi(label, jovenes.count, "users", :green, link: link),
        kpi("Enfermería", InfirmaryVisit.adentro.where(participant_id: jovenes.select(:id)).count, "heart-pulse", :rose,
            badge: "Ahora", link: :infirmary),
        kpi("Asistencia", present || "—", "moon-star", :indigo,
            sub: present ? "de #{jovenes.count} · #{night}" : "Sin pasar", link: :night_attendance)
      ]
    end

    # Los presentes de la última noche que ya se pudo pasar (de día, la de anoche; desde las 6 pm, la de hoy),
    # y cómo llamarla. nil si nadie pasó lista esa noche.
    def night_attendance_present(jovenes)
      now = Time.current
      night = NightAttendance.current_night(now)
      night -= 1 if now.hour.between?(NightAttendance::NIGHT_ENDS_AT, 17)
      marks = NightAttendanceMark.joins(:night_attendance).where(night_attendances: { night_on: night }, participant_id: jovenes.select(:id))
      return [ nil, nil ] unless marks.exists?

      [ marks.presente.count, night == NightAttendance.current_night(now) ? "esta noche" : "anoche" ]
    end

    # Dirección y el superadmin: el evento entero.
    def direction_kpis
      [
        kpi("Jóvenes", total_jovenes, "users", :green, link: :participants),
        kpi("Staff", total_staff, "user-star", :amber, link: :staff),
        kpi("Enfermería", InfirmaryVisit.adentro.count, "heart-pulse", :rose, badge: "Ahora", link: :infirmary)
      ]
    end

    def logistics_director_kpis
      [
        kpi("Mi comité", Participant.where(rol: %w[logistica director_logistica]).count, "users", :teal, link: :logistics_areas),
        arrivals_kpi,
        kpi("Por reponer", InventoryItem.low.count, "package", :amber, sub: "Inventario", link: :inventories)
      ]
    end

    # Logística: según la bandera de su área (Registro, Enfermería, Finanzas); sin bandera, su equipo y el evento.
    def logistics_kpis
      area = @user.participant.logistics_area
      team = kpi("Mi equipo", area ? area.members.count : 1, "users", :teal, sub: area&.name)
      if area&.checkin?
        arrived = arrived_jovenes
        [ arrivals_kpi, kpi("Por llegar", total_jovenes - arrived, "clock", :amber, link: :checkins), team ]
      elsif area&.nursing?
        [
          kpi("Adentro", InfirmaryVisit.adentro.count, "heart-pulse", :rose, badge: "Ahora", link: :infirmary),
          kpi("En camino", InfirmaryVisit.en_camino.count, "footprints", :amber, link: :infirmary),
          kpi("Atendidos", InfirmaryVisit.admitted_on(Date.current).count, "clipboard-check", :green, badge: "Hoy", link: :infirmary)
        ]
      elsif area&.finance?
        [
          kpi("Por aprobar", Expense.presented.count, "wallet", :amber, sub: "Gastos", link: :finances),
          kpi("Por consolidar", Expense.approved.count, "receipt", :indigo, sub: "Sin factura", link: :finances),
          team
        ]
      else
        [ team, kpi("Jóvenes", total_jovenes, "user", :green, link: :participants), kpi("Staff", total_staff, "user-star", :amber, link: :staff) ]
      end
    end

    def arrivals_kpi
      kpi("Llegaron", arrived_jovenes, "scan-line", :blue, sub: "de #{total_jovenes}", link: :checkins)
    end

    def arrived_jovenes
      @arrived_jovenes ||= Checkin.joins(:participant).merge(Participant.jovenes).count
    end
end
