class InventoriesController < ApplicationController
  before_action :require_inventory_access!
  before_action :require_inventory_management!, only: %i[new create edit update destroy]
  before_action :set_inventory, only: %i[show edit update destroy]

  FIELD_LABELS = { "name" => "nombre", "description" => "descripción", "icon" => "icono", "color" => "color" }.freeze

  def index
    @inventories = Inventory.by_name.includes(:items)
  end

  def show
    items = @inventory.items.search(params[:query]).by_name
    items = items.low if params[:filter] == "low"
    @pagy, @items = pagy(items, limit: 25)
  end

  # La cámara vive en su propia pantalla: se escanea y se salta a la ficha del artículo.
  def scan
  end

  def new
    @inventory = Inventory.new
  end

  def create
    @inventory = Inventory.new(inventory_params)
    if @inventory.save
      record_audit!(category: :logistica, action: "created", target: @inventory,
                    summary: "Creó el inventario #{@inventory.name}")
      redirect_to @inventory, notice: "Inventario creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @inventory.update(inventory_params)
      fields = changed_field_labels(@inventory, FIELD_LABELS)
      if fields.any?
        record_audit!(category: :logistica, action: "updated", target: @inventory,
                      summary: "Actualizó #{spanish_list(fields)} del inventario #{@inventory.name}")
      end
      redirect_to @inventory, notice: "Inventario actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @inventory.name
    @inventory.destroy
    record_audit!(category: :logistica, action: "destroyed", target: nil,
                  summary: "Eliminó el inventario #{name} y sus artículos")
    redirect_to inventories_path, status: :see_other, notice: "Inventario eliminado."
  end

  private
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    # El prefijo de los códigos se deriva del nombre y no se cambia: las etiquetas ya impresas mandan.
    def inventory_params
      params.expect(inventory: [ :name, :description, :icon, :color ])
    end
end
