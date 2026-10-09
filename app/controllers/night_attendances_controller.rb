# La asistencia nocturna (ver NightAttendance). El panel (index) es de dirección, coordinadores, auxiliares y el
# director de logística; la lista de cada compañía (show/update) la pasa su consejero del mismo género, o el
# auxiliar de ese género de la rama, y solo la de esta noche.
class NightAttendancesController < ApplicationController
  before_action :require_night_attendance_viewer!, only: :index
  before_action :set_company, :set_gender, :set_night, only: %i[show update]

  def index
    @nights = NightAttendance.panel_nights
    @night = @nights.include?(requested_night) ? requested_night : NightAttendance.default_night
    @companies = Company.includes(:auxiliar_company).order(:number)
    @expected = Participant.joven.where(company_id: @companies.map(&:id)).where.not(gender: nil)
                           .group(:company_id, :gender).pluck(:company_id, :gender, Arel.sql("array_agg(participants.id)"))
                           .each_with_object({}) { |(company_id, gender, ids), map| map[[ company_id, gender ]] = ids }
    @attendances = NightAttendance.where(night_on: @night).includes(marks: { participant: :company })
                                  .index_by { |attendance| [ attendance.company_id, attendance.gender ] }
    @absences = @attendances.values.flat_map { |attendance| attendance.marks.select(&:ausente?) }
  end

  def show
    return show_practice if practice_mode? && practice_company == @company

    @attendance = NightAttendance.includes(marks: :participant).find_by(company: @company, night_on: @night, gender: @gender)
    @jovenes = NightAttendance.expected(@company, @gender).to_a
    @editable = editable?
    set_in_infirmary
  end

  def update
    # La lista de práctica del tutorial nunca se guarda (y sus jóvenes no existen fuera de él).
    return redirect_to company_night_attendance_path(@company, genero: @gender), notice: "Práctica del tutorial: la lista no se guardó." if practice_mode?

    return redirect_to company_night_attendance_path(@company, genero: @gender), alert: "Esta lista no te toca pasarla" unless editable?

    @attendance = NightAttendance.includes(marks: :participant).find_or_initialize_by(company: @company, night_on: @night, gender: @gender)
    first_time = @attendance.new_record?
    if @attendance.record(marks_params, taken_by: Current.user.participant)
      record_audit!(category: :asistencia, action: first_time ? "created" : "updated", target: @company, summary: audit_summary(first_time))
      redirect_to company_night_attendance_path(@company, genero: @gender, return_to: params[:return_to].presence), notice: "Asistencia confirmada."
    else
      @jovenes = NightAttendance.expected(@company, @gender).to_a
      @editable = true
      set_in_infirmary
      render :show, status: :unprocessable_entity
    end
  end

  private
    # En el tutorial: la lista de esta noche solo con los jóvenes de práctica de este género, para marcarlos y
    # confirmar sin tocar la de verdad.
    def show_practice
      @practice = true
      @attendance = nil
      @jovenes = Participant.practice_jovenes_for(@company).select { |joven| joven.gender == @gender }
      @editable = true
      @in_infirmary = Set.new
      render :show
    end

    def require_night_attendance_viewer!
      redirect_to dashboard_path, alert: "El conteo es de dirección, coordinadores y auxiliares" unless can_view_night_attendance?
    end

    def set_company
      @company = Company.find(params[:company_id])
      redirect_to dashboard_path, alert: "No tienes acceso al conteo de esta compañía" unless can_open_night_attendance?(@company)
    end

    # La lista que se abre: la pedida, o la que le toca pasar a quien entra.
    def set_gender
      @own_gender = night_attendance_gender_for(@company)
      @gender = NightAttendance.genders.key?(params[:genero]) ? params[:genero] : (@own_gender || "H")
    end

    def set_night
      @night = requested_night
    end

    def requested_night
      Date.iso8601(params[:noche].to_s)
    rescue Date::Error
      NightAttendance.current_night
    end

    # Quién de la lista sigue en enfermería (o va en camino): su fila llega marcada «ausente · Enfermería»
    # mientras nadie la haya marcado de otra forma. El consejero la confirma con el resto.
    def set_in_infirmary
      @in_infirmary = InfirmaryVisit.ongoing.where(participant_id: @jovenes.map(&:id)).pluck(:participant_id).to_set
    end

    def editable?
      can_take_night_attendance?(@company, @gender, @night)
    end

    def marks_params
      params.fetch(:marks, {}).permit(params.fetch(:marks, {}).keys.index_with { %i[status absence_reason absence_detail] }).to_h
    end

    def audit_summary(first_time)
      absent = @attendance.marks.count(&:ausente?)
      present = @attendance.marks.size - absent
      verb = first_time ? "Pasó" : "Corrigió"
      tally = [ ActionController::Base.helpers.pluralize(present, "presente"), ActionController::Base.helpers.pluralize(absent, "ausente") ].join(" y ")
      "#{verb} el conteo de #{@attendance.label}: #{tally}"
    end
end
