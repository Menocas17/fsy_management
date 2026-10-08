class AgendaController < ApplicationController
  # The agenda only ever shows the days of the event: there is nowhere else to navigate to.
  def show
    @view = params[:view] == "dia" ? "dia" : "semana"
    @days = event_days
    @selected_day = (parse_date(params[:date]) || default_day).clamp(@days.first, @days.last)
    @previous_day = @selected_day - 1 if @selected_day > @days.first
    @next_day = @selected_day + 1 if @selected_day < @days.last
    @visible_days = @view == "semana" ? @days : [ @selected_day ]
    # La agenda es la misma para todos: sus listas van en caché con esta versión (cuántas actividades hay y la
    # última edición), y las actividades solo se cargan si la caché no la tiene (activities_by_day).
    @agenda_version = event_activities.unscope(:order).pick(Arel.sql("COUNT(*)"), Arel.sql("MAX(updated_at)"))
    @activity = selected_activity
  end

  # En el teléfono cada actividad se abre en su lugar, y su detalle se pide recién al abrirla: dibujar el de
  # las ~55 actividades de la semana en cada visita era la mitad del tiempo de la página.
  def activity
    activity = Activity.includes(responsibles: Participant::AVATAR_PRELOAD).find(params[:id])
    render partial: "agenda/details_frame", locals: { activity: activity }
  end

  helper_method :activities_by_day, :day_activities, :agenda_hours

  private
    # Las listas no muestran a los responsables: solo el detalle (selected_activity) los carga, con sus fotos.
    def activities_by_day
      @activities_by_day ||= event_activities.group_by(&:day)
    end

    def day_activities
      activities_by_day.fetch(@selected_day, [])
    end

    def agenda_hours
      @agenda_hours ||= grid_hours
    end

    def event_activities
      Activity.between(@days.first, @days.last)
    end

    def event_days
      (Rails.configuration.x.event_start_on..Rails.configuration.x.event_end_on).to_a
    end

    def default_day
      @days.include?(Date.current) ? Date.current : @days.first
    end

    # La del panel de detalle: la pedida, o la primera del día, o la primera del evento.
    def selected_activity
      activities = Activity.includes(responsibles: Participant::AVATAR_PRELOAD)
      return activities.find_by(id: params[:activity_id]) if params[:activity_id].present?

      activities.between(@selected_day, @selected_day).first || activities.between(@days.first, @days.last).first
    end

    def parse_date(value)
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    # The grid spans the event's own hours, never less than 7:00–21:00.
    def grid_hours
      times = activities_by_day.values.flatten.flat_map { |activity| [ activity.starts_at, activity.ends_at ] }
      first_hour = [ times.map(&:hour).min || 7, 6 ].max
      last_hour = [ times.map { |time| time.min.positive? ? time.hour + 1 : time.hour }.max || 21, 22 ].min

      ([ first_hour, 7 ].min...[ last_hour, 21 ].max).to_a
    end
end
