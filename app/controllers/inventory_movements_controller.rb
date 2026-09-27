class InventoryMovementsController < ApplicationController
  before_action :require_inventory_access!
  before_action :set_item

  def create
    quantity = params[:quantity].to_i.abs
    sign = params[:sign].to_s == "-1" ? -1 : 1
    return redirect_back_with("Escribí una cantidad mayor que cero.") if quantity.zero?

    movement = @item.movements.build(delta: quantity * sign, participant: Current.user&.participant,
                                     reason: reason_param(sign), note: params[:note].presence,
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

    # El motivo por defecto también depende del signo: sumando nada se entrega a las compañías.
    def reason_param(sign)
      allowed = InventoryMovement.reasons_for(sign.positive? ? :in : :out)
      allowed.key?(params[:reason].to_s) ? params[:reason] : allowed.keys.first
    end

    # Se vuelve a donde se hizo el ajuste: la tabla del inventario o la ficha del artículo.
    def redirect_back_with(alert, notice: nil)
      redirect_to return_path, alert: alert, notice: notice
    end

    # Sin el «abrí el cuadro» de la URL: si no, al volver del escaneo el diálogo reaparece encima del
    # resultado, con la cantidad en 1 y tapando el aviso, y parece que el ajuste no se guardó.
    # A cambio se marca que el ajuste vino de un escaneo, para ofrecer seguir con la siguiente caja.
    def return_path
      referer = request.referer
      return inventory_item_path(@item, chained_params) if referer.blank?

      uri = URI.parse(referer)
      query = Rack::Utils.parse_nested_query(uri.query).except("ajuste", "origen").merge(chained_params.stringify_keys)
      [ uri.path, query.presence&.to_query ].compact_blank.join("?")
    rescue URI::InvalidURIError
      inventory_item_path(@item, chained_params)
    end

    # `escaneado` solo enciende el botón de seguir escaneando; el origen del movimiento ya quedó guardado.
    def chained_params
      scanned? ? { escaneado: 1 } : {}
    end

    def scanned?
      params[:source].to_s == "escaneo"
    end
end
