# La reserva de consejeros (Participant#reserve!): quien entra no se borra, pero desaparece de las listas, las
# cifras y las tablas de la app (default_scope de Participant). Desde aquí se devuelve o se borra para siempre.
# Solo acceso total.
class ReservesController < ApplicationController
  before_action :require_reserve_manager!
  before_action :set_reserved, only: %i[restore destroy]

  def index
    @participants = Participant.in_reserve.includes(:user, Participant::AVATAR_PRELOAD).order(reserved_at: :desc, id: :desc)
  end

  def create
    participant = Participant.find(params[:participant_id])
    unless participant.reservable?
      return redirect_to participant_path(participant), alert: "Solo los consejeros pasan a la reserva."
    end

    company = participant.company
    participant.reserve!
    record_audit!(category: :participantes, action: "reserved", target: participant,
                  summary: "Pasó a #{participant.full_name} a la reserva#{" (dejó la #{company.name})" if company}")
    redirect_to reserves_path, status: :see_other, notice: "#{participant.full_name} quedó en la reserva."
  end

  def restore
    @participant.restore_from_reserve!
    record_audit!(category: :participantes, action: "restored", target: @participant,
                  summary: "Devolvió a #{@participant.full_name} de la reserva")
    redirect_to participant_path(@participant), status: :see_other,
                notice: "#{@participant.full_name} volvió a la app. Falta asignarle compañía y cuarto."
  end

  def destroy
    unless @participant.destroy
      return redirect_to reserves_path, alert: "No se pudo borrar: #{@participant.errors.full_messages.to_sentence.presence || "inténtalo de nuevo"}."
    end

    record_audit!(category: :participantes, action: "destroyed", target: @participant,
                  summary: "Borró definitivamente de la reserva a #{@participant.full_name}")
    redirect_to reserves_path, status: :see_other, notice: "#{@participant.full_name} fue borrado definitivamente."
  end

  private
    def set_reserved
      @participant = Participant.in_reserve.find(params[:id])
    end

    def require_reserve_manager!
      redirect_to dashboard_path, alert: "Acceso no autorizado" unless can_manage_reserve?
    end
end
