# La configuración del hotel: sus pasillos (orden, de quién son, si son largos) y los cuartos de cada uno con sus
# camas y para quién están apartados. La primera vez se carga el plano del hotel del evento (Hallway.load_layout!).
class HallwaysController < ApplicationController
  before_action :require_rooms_manager!
  before_action :set_hallway, only: %i[edit update destroy]

  FIELD_LABELS = { "name" => "nombre", "position" => "orden", "gender" => "de quién es", "long" => "largo" }.freeze

  def index
    @hallways = Hallway.ordered.includes(:rooms).to_a
  end

  def new
    @hallway = Hallway.new(position: Hallway.maximum(:position).to_i + 1, new_rooms_capacity: Room::DEFAULT_CAPACITY)
  end

  def create
    @hallway = Hallway.new(hallway_params)
    if @hallway.save
      record_audit!(category: :cuartos, action: "created", target: @hallway,
                    summary: "Creó el pasillo #{@hallway.name} con #{helpers.pluralize(@hallway.rooms.size, "cuarto")}")
      redirect_to hallways_path, notice: "Pasillo creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @hallway.new_rooms_capacity = Room::DEFAULT_CAPACITY
  end

  def update
    before = @hallway.rooms.map { |room| [ room.id, [ room.number, room.capacity, room.purpose ] ] }.to_h
    if @hallway.update(hallway_params)
      audit_update(before)
      redirect_to hallways_path, notice: "Pasillo actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @hallway.name
    count = @hallway.rooms.size
    @hallway.destroy!
    record_audit!(category: :cuartos, action: "destroyed", target: nil,
                  summary: "Eliminó el pasillo #{name} y sus #{helpers.pluralize(count, "cuarto")}")
    redirect_to hallways_path, status: :see_other, notice: "Pasillo eliminado. Quien dormía en sus cuartos conserva el número en su ficha."
  end

  # El plano del hotel del evento, solo si todavía no hay pasillos.
  def load_layout
    count = Hallway.load_layout!
    if count.zero?
      redirect_to hallways_path, alert: "El hotel ya tiene pasillos: se configuran a mano."
    else
      record_audit!(category: :cuartos, action: "created", target: nil,
                    summary: "Cargó el plano del #{Hallway.layout_name}: #{helpers.pluralize(count, "pasillo")} y #{helpers.pluralize(Room.count, "cuarto")}")
      redirect_to hallways_path, notice: "Listo: #{helpers.pluralize(count, "pasillo")} y #{helpers.pluralize(Room.count, "cuarto")} de #{Room::DEFAULT_CAPACITY} camas. Corrige las camas de cada cuarto."
    end
  end

  private
    def set_hallway
      @hallway = Hallway.includes(:rooms).find(params[:id])
    end

    def hallway_params
      params.expect(hallway: [ :name, :position, :gender, :long, :new_rooms, :new_rooms_capacity,
                               rooms_attributes: [ [ :id, :number, :capacity, :purpose, :_destroy ] ] ]).tap do |permitted|
        permitted[:gender] = nil if permitted.key?(:gender) && permitted[:gender].blank?
      end
    end

    def audit_update(before)
      fields = changed_field_labels(@hallway, FIELD_LABELS)
      after = @hallway.rooms.reload.to_h { |room| [ room.id, [ room.number, room.capacity, room.purpose ] ] }
      added = (after.keys - before.keys).size
      removed = (before.keys - after.keys).size
      edited = (before.keys & after.keys).count { |id| before[id] != after[id] }
      fields << "#{helpers.pluralize(edited, "cuarto")}" if edited.positive?
      fields << "agregó #{helpers.pluralize(added, "cuarto")}" if added.positive?
      fields << "quitó #{helpers.pluralize(removed, "cuarto")}" if removed.positive?
      return if fields.empty?

      record_audit!(category: :cuartos, action: "updated", target: @hallway,
                    summary: "Actualizó el pasillo #{@hallway.name}: #{spanish_list(fields)}")
    end
end
