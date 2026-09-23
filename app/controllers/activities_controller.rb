class ActivitiesController < ApplicationController
  before_action :require_agenda_manager!
  before_action :set_activity, only: %i[edit update destroy]

  FIELD_LABELS = {
    "title" => "título", "category" => "tipo", "starts_at" => "hora de inicio", "ends_at" => "hora de fin",
    "location" => "lugar", "description" => "descripción", "audience" => "destinatarios",
    "logistics_notes" => "notas de logística", "counselors_notes" => "notas de consejeros", "youth_notes" => "notas de jóvenes"
  }.freeze

  def new
    @activity = Activity.new(date: params[:date] || Date.current.to_s, start_time: "08:00", end_time: "09:00",
                             category: :actividad, audience: :todos)
  end

  def create
    @activity = Activity.new(activity_params)

    if @activity.save
      Alert.announce(@activity, action: :created, user: Current.user)
      record_audit!(category: :agenda, action: "created", target: @activity,
                    summary: "Agregó «#{@activity.title}» a la agenda")
      redirect_to agenda_path(date: @activity.day, activity_id: @activity.id), notice: "Actividad creada. Se envió la alerta a #{@activity.audience_label.downcase}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @activity.date = @activity.starts_at.to_date.to_s
    @activity.start_time = @activity.starts_at.strftime("%H:%M")
    @activity.end_time = @activity.ends_at.strftime("%H:%M")
  end

  def update
    if @activity.update(activity_params)
      fields = changed_field_labels(@activity, FIELD_LABELS)
      if fields.any?
        Alert.announce(@activity, action: :updated, user: Current.user, detail: "Cambió #{spanish_list(fields)}.")
        record_audit!(category: :agenda, action: "updated", target: @activity,
                      summary: "Actualizó #{spanish_list(fields)} de «#{@activity.title}»")
      end
      redirect_to agenda_path(date: @activity.day, activity_id: @activity.id), notice: notice_for(fields)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    day = @activity.day
    Alert.announce(@activity, action: :cancelled, user: Current.user)
    record_audit!(category: :agenda, action: "destroyed", target: @activity,
                  summary: "Quitó «#{@activity.title}» de la agenda")
    @activity.destroy

    redirect_to agenda_path(date: day), status: :see_other, notice: "Actividad eliminada. Se avisó a los participantes."
  end

  private
    def set_activity
      @activity = Activity.find(params[:id])
    end

    def notice_for(fields)
      fields.any? ? "Actividad actualizada. Se envió la alerta del cambio." : "No hubo cambios que avisar."
    end

    def activity_params
      params.expect(activity: [ :title, :category, :date, :start_time, :end_time, :location, :description,
                                :audience, :logistics_notes, :counselors_notes, :youth_notes,
                                { target_roles: [], responsible_ids: [] } ])
    end
end
