# Agregar o quitar a alguien del comité de un área. Agregar a quien ya está en otra la cambia de área: cada
# persona pertenece a una sola.
class LogisticsAreaMembersController < ApplicationController
  before_action :require_logistics_areas_access!
  before_action :set_area

  def create
    member = Participant.where(rol: %w[logistica director_logistica]).find(params[:participant_id])
    previous = member.logistics_area
    # Sin validar el resto de la ficha: una ficha incompleta no impide armar el área.
    member.update_attribute(:logistics_area_id, @area.id)
    record_audit!(category: :logistica, action: "updated", target: member,
                  summary: "Pasó a #{member.full_name} al área #{@area.name}#{" (estaba en #{previous.name})" if previous && previous != @area}")
    redirect_to logistics_area_path(@area, query: params[:query].presence), notice: "#{member.full_name} ahora está en #{@area.name}."
  end

  def destroy
    member = @area.members.find(params[:id])
    member.update_attribute(:logistics_area_id, nil)
    record_audit!(category: :logistica, action: "updated", target: member,
                  summary: "Quitó a #{member.full_name} del área #{@area.name}")
    redirect_to logistics_area_path(@area), status: :see_other, notice: "#{member.full_name} quedó sin área."
  end

  private
    def set_area
      @area = LogisticsArea.find(params[:logistics_area_id])
    end
end
