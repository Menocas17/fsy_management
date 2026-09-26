class InventoryItemsController < ApplicationController
  before_action :require_inventory_access!
  before_action :set_inventory, only: %i[new create]
  before_action :set_item, only: %i[show edit update]

  FIELD_LABELS = { "name" => "nombre", "unit" => "unidad", "minimum" => "mínimo", "location" => "ubicación", "notes" => "notas" }.freeze

  def show
    @movements = @item.movements.includes(:participant).limit(30)
  end

  # Llega aquí lo que escanea la cámara y lo que se escribe a mano: si el código no existe, se avisa.
  def lookup
    code = params[:code].to_s.strip.upcase
    item = InventoryItem.find_by(code: code)

    if item
      redirect_to inventory_item_path(item, ajuste: 1, origen: "escaneo")
    else
      redirect_to scan_inventories_path, alert: "No encontramos ningún artículo con el código #{code.presence || '(vacío)'}."
    end
  end

  def new
    @item = @inventory.items.build(unit: "u")
  end

  def create
    @item = @inventory.items.build(item_params)
    starting = params[:inventory_item][:starting_quantity].to_i

    if @item.save
      # La existencia inicial también es un movimiento: así el historial arranca cuadrado.
      @item.adjust!(delta: starting, participant: Current.user&.participant, reason: :inicial) if starting.positive?
      record_audit!(category: :logistica, action: "created", target: @item,
                    summary: "Agregó #{@item.name} al inventario #{@inventory.name}")
      redirect_to @item, notice: "Artículo agregado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      fields = changed_field_labels(@item, FIELD_LABELS)
      if fields.any?
        record_audit!(category: :logistica, action: "updated", target: @item,
                      summary: "Actualizó #{spanish_list(fields)} de #{@item.name}")
      end
      redirect_to @item, notice: "Artículo actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_inventory
      @inventory = Inventory.find(params[:inventory_id])
    end

    def set_item
      @item = InventoryItem.includes(:inventory).find_by!(code: params[:id])
      @inventory = @item.inventory
    end

    # La existencia no se edita a mano en ningún lado: solo la mueven los ajustes.
    def item_params
      params.expect(inventory_item: [ :name, :unit, :minimum, :location, :notes ])
    end
end
