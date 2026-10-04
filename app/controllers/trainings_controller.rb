# El resumen de capacitaciones, dentro de la agenda. Lo ve cualquiera del staff; crearlas, cambiarlas o
# borrarlas es de quien edita la agenda, y marcar a mano, del mismo comité que registra llegadas.
class TrainingsController < ApplicationController
  before_action :require_agenda_manager!, except: %i[index show]
  before_action :set_training, only: %i[show edit update destroy]

  def index
    @trainings = Training.chronological.to_a
    @staff = Participant.staff.includes(:company, :logistics_area).order(:first_name, :last_name)
    # Una sola consulta para toda la tabla: quién asistió a qué.
    @attended = TrainingAttendance.pluck(:training_id, :participant_id).group_by(&:first)
                                  .transform_values { |pairs| pairs.map(&:last).to_set }
    @by_role = (@trainings.select(&:past?).last || @trainings.first)&.role_breakdown || {}
  end

  def show
  end

  def new
    @training = Training.new(name: suggested_name, held_on: params[:held_on].presence || Date.current)
  end

  def create
    @training = Training.new(training_params)

    if @training.save
      record_audit!(category: :agenda, action: "created", target: @training,
                    summary: "Agregó la capacitación «#{@training.name}» (#{SpanishDates.long(@training.held_on, capitalize: false)})")
      redirect_to agenda_training_path(@training), notice: "Capacitación creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @training.update(training_params)
      record_audit!(category: :agenda, action: "updated", target: @training,
                    summary: "Editó la capacitación «#{@training.name}»")
      redirect_to agenda_training_path(@training), notice: "Capacitación actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @training.name
    @training.destroy!
    record_audit!(category: :agenda, action: "deleted", target: @training, summary: "Borró la capacitación «#{name}»")
    redirect_to agenda_trainings_path, notice: "Se borró la capacitación «#{name}»."
  end

  private
    def set_training
      @training = Training.find(params[:id])
    end

    # El escaneo no va aquí: el registro activo se elige desde Configuración (ScanWindow).
    def training_params
      params.expect(training: [ :name, :held_on, :location, :notes ])
    end

    NUMERALS = %w[Primera Segunda Tercera Cuarta Quinta Sexta Séptima Octava Novena Décima].freeze

    # «Cuarta capacitación» si ya hay tres: casi siempre es el nombre que se iba a escribir.
    def suggested_name
      "#{NUMERALS[Training.count] || "Nueva"} capacitación"
    end
end
