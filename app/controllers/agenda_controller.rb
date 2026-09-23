class AgendaController < ApplicationController
  # The agenda only ever shows the days of the event: there is nowhere else to navigate to.
  def show
    @view = params[:view] == "dia" ? "dia" : "semana"
    @days = event_days
    @selected_day = (parse_date(params[:date]) || default_day).clamp(@days.first, @days.last)
    @previous_day = @selected_day - 1 if @selected_day > @days.first
    @next_day = @selected_day + 1 if @selected_day < @days.last
    @visible_days = @view == "semana" ? @days : [ @selected_day ]

    activities = Activity.includes(responsibles: :avatar_attachment)
    @activities_by_day = activities.between(@days.first, @days.last).group_by(&:day)
    @day_activities = @activities_by_day.fetch(@selected_day, [])
    @hours = grid_hours
    @activity = selected_activity
  end

  private
    def event_days
      (Rails.configuration.x.event_start_on..Rails.configuration.x.event_end_on).to_a
    end

    def default_day
      @days.include?(Date.current) ? Date.current : @days.first
    end

    def selected_activity
      return Activity.find_by(id: params[:activity_id]) if params[:activity_id].present?

      @day_activities.first || @activities_by_day.values.flatten.first
    end

    def parse_date(value)
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end

    # The grid spans the event's own hours, never less than 7:00–21:00.
    def grid_hours
      times = @activities_by_day.values.flatten.flat_map { |activity| [ activity.starts_at, activity.ends_at ] }
      first_hour = [ times.map(&:hour).min || 7, 6 ].max
      last_hour = [ times.map { |time| time.min.positive? ? time.hour + 1 : time.hour }.max || 21, 22 ].min

      ([ first_hour, 7 ].min...[ last_hour, 21 ].max).to_a
    end
end
