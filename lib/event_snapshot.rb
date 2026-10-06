# Una foto de los datos del evento (las fichas y todo lo que cuelga de ellas) en un JSON del repo, para volver a
# dejar cualquier base exactamente así: `bin/rails datos:exportar` la toma de la base local y
# `bin/rails datos:sembrar` la carga después de borrar (EventReset). Las filas entran tal cual, con sus mismos
# ids y fechas (insert_all, sin callbacks): rápido incluso contra Neon y sin que nada se recalcule distinto.
#
# Lo que es configuración de cada base no se copia por id, se busca por su nombre (las áreas de logística,
# las categorías de gasto) o por su fecha (las capacitaciones): si existe se usa la que hay, y si no se crea.
# No van cuentas, sesiones, historial, alertas (llegarían como notificación) ni fotos.
class EventSnapshot
  PATH = Rails.root.join("db/seed_data/evento.json")

  # En orden de carga: cada tabla después de las que referencia.
  TABLES = [
    AuxiliarCompany, Company, Participant, Membership,
    Activity, ActivityResponsible, Assignment,
    Inventory, InventoryItem, InventoryMovement,
    TrainingAttendance, Expense,
    NightAttendance, NightAttendanceMark
  ].freeze

  # Por nombre o fecha, no por id: [modelo, la llave, los campos que se copian].
  MATCHED = {
    "logistics_areas" => [ LogisticsArea, :name, %w[name description checkin finance food nursing] ],
    "expense_categories" => [ ExpenseCategory, :name, %w[name budget_cents icon color] ],
    "trainings" => [ Training, :held_on, %w[name held_on location notes] ]
  }.freeze

  # Las columnas que apuntan a lo que se busca por nombre: se traducen al id de esta base.
  REMAPPED = {
    "logistics_area_id" => "logistics_areas", "expense_category_id" => "expense_categories", "training_id" => "trainings"
  }.freeze

  def self.dump(path = PATH)
    data = MATCHED.to_h { |table, (model, *)| [ table, model.order(:created_at, :id).map(&:attributes) ] }
    TABLES.each { |model| data[model.table_name] = model.order(:created_at, :id).map(&:attributes) }
    # Sin el enlace a la nota clínica: la enfermería no se copia.
    data["inventory_movements"].each { |row| row["infirmary_note_id"] = nil }
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(data))
    data.transform_values(&:size)
  end

  def self.data(path = PATH)
    JSON.parse(File.read(path))
  end

  # Las áreas de la foto que esta base no tiene (se crearían al cargarla).
  def self.missing_areas(path = PATH)
    existing = LogisticsArea.pluck(:name).map { |name| normalize(name) }
    data(path)["logistics_areas"].map { |row| row["name"] }.reject { |name| existing.include?(normalize(name)) }
  end

  def self.normalize(value)
    ImportRowEvaluator.normalize(value)
  end

  def initialize(path = PATH, out: $stdout)
    @path = path
    @data = self.class.data(path)
    @out = out
  end

  # Borra como `datos:reiniciar` (EventReset) y carga la foto, todo o nada.
  def run
    ActiveRecord::Base.transaction do
      @out.puts "Borrando los datos anteriores…"
      EventReset.new(out: StringIO.new).run
      @out.puts "Cargando #{File.basename(@path)}…"
      Activity.destroy_all
      ids = MATCHED.to_h { |table, spec| [ table, match(table, *spec) ] }
      TABLES.each do |model|
        rows = @data.fetch(model.table_name, []).map { |row| remap(row, ids) }
        model.insert_all!(rows) if rows.any?
        @out.puts format("  %-28s %5d", model.table_name, rows.size)
      end
      AuditLog.create!(actor_name: "Administrador del sistema", action: "created", category: :participantes,
                       summary: "Cargó los datos de prueba: #{Participant.count} fichas en #{Company.count} compañías")
    end
    @out.puts "Listo."
  end

  private
    # { id de la foto => id en esta base }, creando lo que falte.
    def match(table, model, key, fields)
      @data.fetch(table, []).to_h do |row|
        wanted = row[key.to_s]
        record = if key == :name
          model.all.find { |existing| self.class.normalize(existing.name) == self.class.normalize(wanted) }
        else
          model.find_by(key => wanted)
        end
        record ||= model.create!(row.slice(*fields))
        record.update!(row.slice(*fields).except("name")) if table == "trainings"
        [ row["id"], record.id ]
      end
    end

    def remap(row, ids)
      REMAPPED.each_with_object(row.dup) do |(column, table), copy|
        copy[column] = ids[table][copy[column]] if copy.key?(column) && copy[column]
      end
    end
end
