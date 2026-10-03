# Las áreas del comité de logística. Las banderas de un área (LogisticsArea::FLAGS) dan permisos a todos sus
# miembros: quién registra llegadas, quién lleva las finanzas, quién tendrá alimentación. Los miembros se
# agregan y quitan en LogisticsAreaMembersController.
class LogisticsAreasController < ApplicationController
  before_action :require_logistics_areas_access!
  before_action :set_area, only: %i[show edit update destroy]

  FIELD_LABELS = { "name" => "nombre", "description" => "descripción" }.freeze

  def index
    @areas = LogisticsArea.alphabetical.includes(:members)
    @committee_count = committee.count
    @unassigned = committee.where(logistics_area_id: nil).order(:first_name, :last_name)
  end

  def show
    @members = @area.members.order(:first_name, :last_name)
    candidates = committee.where.not(logistics_area_id: @area.id).or(committee.where(logistics_area_id: nil))
                          .includes(:logistics_area).order(:first_name, :last_name)
    @candidates = params[:query].present? ? candidates.search_by_name(params[:query]) : candidates
  end

  def new
    @area = LogisticsArea.new
  end

  def create
    @area = LogisticsArea.new(area_params)
    if @area.save
      record_audit!(category: :logistica, action: "created", target: @area, summary: "Creó el área de logística #{@area.name}")
      redirect_to @area, notice: "Área creada. Ahora agrégale miembros."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  # Además del formulario, aquí llegan los interruptores de las banderas (uno por envío).
  def update
    if @area.update(area_params)
      audit_update
      redirect_to @area, notice: params[:logistics_area].keys.intersect?(LogisticsArea::FLAGS.keys.map(&:to_s)) ? "Permisos actualizados." : "Área actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @area.name
    count = @area.members.count
    if @area.destroy
      record_audit!(category: :logistica, action: "destroyed", target: nil,
                    summary: "Eliminó el área de logística #{name}#{" (#{count} quedaron sin área)" if count.positive?}")
      redirect_to logistics_areas_path, status: :see_other, notice: "Área eliminada."
    else
      redirect_to @area, alert: "No se puede borrar: tiene gastos registrados. Cámbiale el nombre si ya no se usa."
    end
  end

  private
    def set_area
      @area = LogisticsArea.find(params[:id])
    end

    # Los miembros posibles: todo el comité de logística, su director incluido.
    def committee
      Participant.where(rol: %w[logistica director_logistica])
    end

    def area_params
      params.expect(logistics_area: [ :name, :description, *LogisticsArea::FLAGS.keys ])
    end

    def audit_update
      LogisticsArea::FLAGS.each do |flag, (label, _)|
        next unless @area.saved_change_to_attribute?(flag)

        record_audit!(category: :logistica, action: "updated", target: @area,
                      summary: "#{@area.public_send(flag) ? "Dio" : "Quitó"} el permiso de #{label} #{@area.public_send(flag) ? "al" : "del"} área #{@area.name}")
      end
      fields = changed_field_labels(@area, FIELD_LABELS)
      return if fields.empty?

      record_audit!(category: :logistica, action: "updated", target: @area,
                    summary: "Actualizó #{spanish_list(fields)} del área de logística #{@area.name}")
    end
end
