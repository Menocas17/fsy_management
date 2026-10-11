# El ordenamiento de cuartos (RoomPlanner): show arma una propuesta sin guardar nada (?semilla= para
# «Reordenar», ?llegados=1 para solo quienes ya pasaron por Registro) y create la aplica a las fichas.
class RoomPlansController < ApplicationController
  before_action :require_rooms_manager!
  before_action :set_options

  def show
    @hallways = Hallway.ordered.includes(:rooms).to_a
    return if @hallways.empty?

    @plan = RoomPlanner.new(seed: @seed, arrived_only: @arrived_only, hallways: @hallways).call
    @tiles = helpers.room_tiles_from_plan(@plan, @hallways.flat_map(&:rooms))
    @fingerprint = RoomPlanner.fingerprint(arrived_only: @arrived_only)
    @arrived_count = Participant.joven.where(id: Checkin.select(:participant_id)).count
  end

  def create
    # Si entre la vista previa y el clic cambió alguien, un cuarto o un pasillo, la misma semilla ya no da la
    # misma propuesta: se vuelve a mostrar en vez de aplicar algo que nadie vio.
    if params[:huella] != RoomPlanner.fingerprint(arrived_only: @arrived_only)
      return redirect_to room_plan_path(plan_options), alert: "Algo cambió mientras veías la propuesta. Esta es la nueva: revísala antes de aplicarla."
    end

    plan = RoomPlanner.new(seed: @seed, arrived_only: @arrived_only).call
    changed = plan.apply!
    record_audit!(category: :cuartos, action: "updated", target: nil,
                  summary: "Ordenó los cuartos: #{pluralize(plan.placed_count, "persona")} en #{pluralize(plan.rooms_used, "cuarto")}" \
                           "#{" (solo jóvenes que ya llegaron)" if @arrived_only}")
    redirect_to rooms_path, status: :see_other,
                notice: changed.zero? ? "Los cuartos ya estaban así." : "Cuartos ordenados: #{pluralize(changed, "ficha cambió", plural: "fichas cambiaron")} de cuarto."
  end

  private
    def set_options
      @seed = params[:semilla].presence&.to_i
      @arrived_only = params[:llegados] == "1"
    end

    def plan_options
      { semilla: @seed, llegados: ("1" if @arrived_only) }.compact
    end
    helper_method :plan_options

    def pluralize(count, singular, plural: nil)
      helpers.pluralize(count, singular, plural: plural)
    end
end
