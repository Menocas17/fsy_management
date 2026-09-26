class InventoryMovementsController < ApplicationController
  before_action :require_inventory_access!
  before_action :set_item

  def create
    quantity = params[:quantity].to_i.abs
    sign = params[:sign].to_s == "-1" ? -1 : 1
    return redirect_back_with("Escribí una cantidad mayor que cero.") if quantity.zero?

    movement = @item.movements.build(delta: quantity * sign, participant: Current.user&.participant,
                                     reason: reason_param, note: params[:note].presence,
                                     source: params[:source].to_s == "escaneo" ? :escaneo : :manual)

    if movement.save
      record_audit!(category: :logistica, action: movement.adds? ? "stock_added" : "stock_removed",
                    target: @item,
                    summary: "#{movement.delta_label} #{@item.unit} de #{@item.name} · #{movement.reason_label}")
      redirect_back_with(nil, notice: "#{movement.delta_label} #{@item.unit} · queda en #{@item.reload.quantity_label}")
    else
      redirect_back_with(movement.errors.full_messages.to_sentence)
    end
  end

  private
    def set_item
      @item = InventoryItem.includes(:inventory).find_by!(code: params[:inventory_item_id])
    end

    def reason_param
      InventoryMovement.reasons.key?(params[:reason].to_s) ? params[:reason] : :entrega
    end

    # Se vuelve a donde se hizo el ajuste: la tabla del inventario o la ficha del artículo.
    def redirect_back_with(alert, notice: nil)
      redirect_back fallback_location: @item, alert: alert, notice: notice
    end
end
