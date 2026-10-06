# Lo que EventSeed llena además de las personas, para que cada módulo se vea en uso: la agenda, los
# inventarios (el de medicamentos es el de enfermería), las capacitaciones con su asistencia, las finanzas en
# todas sus etapas y algunas asignaciones. Lo que solo pasa durante el evento (llegadas, enfermería,
# asistencia nocturna) y las alertas (llegarían como notificación a los teléfonos) se quedan vacíos.
class EventSeed::Operations
  # nombre => [ícono, color, descripción, de enfermería, [[artículo, unidad, mínimo, existencia, ubicación], …]]
  INVENTORIES = {
    "Materiales" => [ "package", "primary", "Camisetas, gafetes y papelería", false, [
      [ "Camisetas FSY talla XS", "u", 10, 38, "Bodega 1" ], [ "Camisetas FSY talla S", "u", 20, 142, "Bodega 1" ],
      [ "Camisetas FSY talla M", "u", 25, 196, "Bodega 1" ], [ "Camisetas FSY talla L", "u", 20, 128, "Bodega 1" ],
      [ "Camisetas FSY talla XL", "u", 10, 64, "Bodega 1" ], [ "Gafetes con cordón", "u", 50, 640, "Registro" ],
      [ "Cuadernos FSY", "u", 50, 560, "Bodega 1" ], [ "Lapiceros", "u", 50, 600, "Bodega 1" ],
      [ "Marcadores permanentes", "u", 12, 9, "Bodega 1" ], [ "Resmas de papel", "resmas", 4, 12, "Bodega 1" ],
      [ "Cinta adhesiva", "rollos", 6, 0, "Bodega 1" ]
    ] ],
    "Decoración" => [ "sparkles", "indigo", "Escenario, auditorio y salones de compañía", false, [
      [ "Telas de fondo", "metros", 20, 85, "Bodega 2" ], [ "Globos", "bolsas", 10, 26, "Bodega 2" ],
      [ "Luces LED", "u", 8, 18, "Bodega 2" ], [ "Banderas de compañía", "u", 25, 25, "Bodega 2" ],
      [ "Cartulinas de colores", "pliegos", 30, 120, "Bodega 2" ], [ "Guirnaldas", "u", 10, 7, "Bodega 2" ],
      [ "Cinta doble cara", "rollos", 5, 14, "Bodega 2" ]
    ] ],
    "Alimentación" => [ "utensils", "amber", "Refrigerios, bebidas y desechables", false, [
      [ "Botellas de agua 600 ml", "u", 300, 2400, "Comedores" ], [ "Galletas", "cajas", 20, 64, "Comedores" ],
      [ "Jugos", "cajas", 20, 15, "Comedores" ], [ "Café", "libras", 5, 22, "Comedores" ],
      [ "Azúcar", "libras", 10, 40, "Comedores" ], [ "Vasos desechables", "paquetes", 20, 90, "Comedores" ],
      [ "Platos desechables", "paquetes", 20, 85, "Comedores" ], [ "Servilletas", "paquetes", 15, 60, "Comedores" ]
    ] ],
    "Medicamentos" => [ "pill", "rose", "Lo que enfermería da desde la ficha clínica", true, [
      [ "Acetaminofén 500 mg", "tabletas", 100, 600, "Enfermería" ], [ "Ibuprofeno 400 mg", "tabletas", 60, 300, "Enfermería" ],
      [ "Loratadina 10 mg", "tabletas", 30, 120, "Enfermería" ], [ "Suero oral", "sobres", 40, 150, "Enfermería" ],
      [ "Omeprazol 20 mg", "cápsulas", 20, 60, "Enfermería" ], [ "Dimenhidrinato 50 mg", "tabletas", 20, 18, "Enfermería" ],
      [ "Salbutamol inhalador", "u", 2, 4, "Enfermería" ], [ "Antiácido masticable", "tabletas", 30, 90, "Enfermería" ],
      [ "Crema para quemaduras", "tubos", 3, 6, "Enfermería" ], [ "Clorfenamina 4 mg", "tabletas", 20, 0, "Enfermería" ]
    ] ],
    "Material de curación" => [ "bandage", "pink", "Botiquín de enfermería", true, [
      [ "Curitas", "cajas", 6, 20, "Enfermería" ], [ "Gasas estériles", "paquetes", 10, 40, "Enfermería" ],
      [ "Vendas elásticas", "u", 6, 15, "Enfermería" ], [ "Alcohol 70 %", "litros", 2, 6, "Enfermería" ],
      [ "Guantes desechables", "cajas", 3, 8, "Enfermería" ], [ "Bolsas de hielo instantáneo", "u", 10, 8, "Enfermería" ]
    ] ],
    "Utensilios" => [ "wrench", "slate", "Herramientas y utensilios de uso general", false, [
      [ "Tijeras", "u", 6, 20, "Bodega 1" ], [ "Engrapadoras", "u", 4, 10, "Bodega 1" ],
      [ "Extensiones eléctricas", "u", 6, 14, "Bodega 3" ], [ "Linternas", "u", 10, 30, "Bodega 3" ],
      [ "Hieleras", "u", 4, 8, "Comedores" ], [ "Escobas", "u", 6, 12, "Bodega 3" ],
      [ "Baldes", "u", 6, 10, "Bodega 3" ], [ "Mesas plegables", "u", 10, 24, "Bodega 3" ]
    ] ],
    "Audio y tecnología" => [ "speaker", "violet", "Sonido, proyección y equipos de registro", false, [
      [ "Micrófonos inalámbricos", "u", 2, 6, "Auditorio" ], [ "Bocinas", "u", 2, 4, "Auditorio" ],
      [ "Proyector", "u", 1, 2, "Auditorio" ], [ "Cables HDMI", "u", 2, 5, "Auditorio" ],
      [ "Baterías AA", "pares", 20, 16, "Auditorio" ], [ "Cargadores de teléfono", "u", 5, 12, "Registro" ]
    ] ],
    "Deportes" => [ "volleyball", "green", "Olimpiadas y gymkana", false, [
      [ "Balones de fútbol", "u", 4, 10, "Bodega 3" ], [ "Balones de voleibol", "u", 4, 8, "Bodega 3" ],
      [ "Conos", "u", 20, 40, "Bodega 3" ], [ "Chalecos de colores", "u", 25, 50, "Bodega 3" ],
      [ "Silbatos", "u", 5, 12, "Bodega 3" ], [ "Cuerdas", "u", 2, 4, "Bodega 3" ]
    ] ]
  }.freeze

  # Del mes anterior al evento: la primera ya pasó (con su asistencia) y las demás vienen.
  TRAININGS = [
    [ "Primera capacitación del staff", -9, "Capilla Bello Horizonte", "Visión de FSY, roles y normas de seguridad." ],
    [ "Capacitación de consejeros", 47, "Capilla Bello Horizonte", "Cómo acompañar a los jóvenes y pasar la asistencia nocturna." ],
    [ "Primeros auxilios y enfermería", 68, "Capilla Las Américas", "Con el equipo de enfermería: alergias, medicamentos y emergencias." ],
    [ "Ensayo general de registro", 96, "Lugar del evento", "Se prueban los escáneres y las mesas de registro." ]
  ].freeze

  # nombre => [ícono, color, presupuesto en córdobas]
  EXPENSE_CATEGORIES = {
    "Alimentación" => [ "utensils", "amber", 180_000 ], "Transporte" => [ "bus", "blue", 90_000 ],
    "Materiales" => [ "package", "primary", 60_000 ], "Decoración" => [ "sparkles", "indigo", 25_000 ],
    "Enfermería" => [ "heart-pulse", "rose", 20_000 ], "Imprevistos" => [ "wallet", "slate", nil ]
  }.freeze

  # [concepto, categoría, área, proveedor, estimado en C$, etapa, monto real en C$]
  EXPENSES = [
    [ "Camisetas FSY (640)", "Materiales", "Finanzas", "Textiles Managua", 51_200, :consolidated, 49_920 ],
    [ "Buses para el traslado desde Puerto Cabezas", "Transporte", "Finanzas", "Transportes del Caribe", 42_000, :consolidated, 42_000 ],
    [ "Gafetes y cordones", "Materiales", "Registro", "Imprenta La Prensa", 6_400, :consolidated, 6_150 ],
    [ "Refrigerios de la semana", "Alimentación", "Alimentación", "Distribuidora El Sol", 38_500, :approved, nil ],
    [ "Agua embotellada", "Alimentación", "Alimentación", "Distribuidora El Sol", 14_400, :justification_pending, 13_800 ],
    [ "Medicamentos del botiquín", "Enfermería", "Enfermería", "Farmacia Kielsa", 8_900, :approved, nil ],
    [ "Telas y luces del escenario", "Decoración", nil, "Variedades Rosita", 7_500, :presented, nil ],
    [ "Escáneres de mano para registro", "Materiales", "Registro", "Tecnología Total", 9_800, :rejected, nil ],
    [ "Hieleras y vasos", "Alimentación", "Alimentación", "Ferretería Lugo", 3_200, :presented, nil ]
  ].freeze

  def initialize(log:)
    @log = log
    @rng = Random.new(2026)
  end

  def run
    leaders = Participant.where(rol: %i[director coordinador]).order(:rol, :gender).to_a
    @log.call "✔ Agenda: #{EventAgenda.new(hosts: leaders).create} actividades en #{Activity.event_days.count} días"
    create_inventories
    create_trainings
    create_finances
    create_assignments
  end

  private
    def create_inventories
      staff = Participant.where(rol: %i[logistica director_logistica]).to_a
      INVENTORIES.each do |name, (icon, color, description, infirmary, items)|
        inventory = Inventory.find_or_create_by!(name: name) do |record|
          record.assign_attributes(icon: icon, color: color, description: description, infirmary: infirmary)
        end
        items.each do |item_name, unit, minimum, quantity, location|
          item = inventory.items.create!(name: item_name, unit: unit, minimum: minimum, location: location)
          # Se compró un poco más y algo ya se entregó: así el historial tiene de dónde agarrarse.
          delivered = quantity.zero? ? minimum : (quantity * 0.1).ceil
          item.adjust!(delta: quantity + delivered, participant: staff.sample(random: @rng), reason: :inicial)
          item.adjust!(delta: -delivered, participant: staff.sample(random: @rng), reason: :entrega, note: "Para la capacitación")
        end
      end
      @log.call "✔ Inventario: #{InventoryItem.count} artículos en #{Inventory.count} inventarios " \
                "(#{Inventory.for_infirmary.count} de enfermería)"
    end

    def create_trainings
      TRAININGS.each do |name, days_from_today, location, notes|
        Training.find_or_create_by!(held_on: Date.current + days_from_today) do |training|
          training.assign_attributes(name: name, location: location, notes: notes)
        end
      end
      recorder = Participant.director_logistica.first
      staff = Participant.staff.to_a
      Training.where(held_on: ...Date.current).find_each do |training|
        staff.select { @rng.rand < 0.82 }.each do |person|
          TrainingAttendance.create!(training: training, participant: person, recorded_by: recorder, source: :qr,
                                     recorded_at: training.held_on.in_time_zone.change(hour: 8) + @rng.rand(0..90).minutes)
        end
      end
      @log.call "✔ Capacitaciones: #{Training.count}, con #{TrainingAttendance.count} asistencias en las que ya pasaron"
    end

    # Cada paso lo da alguien distinto del anterior, como pide Expense: presenta la logística del área,
    # aprueba la directora de logística y la justificación la aprueba el director.
    def create_finances
      EXPENSE_CATEGORIES.each do |name, (icon, color, budget)|
        ExpenseCategory.find_or_create_by!(name: name) do |category|
          category.assign_attributes(icon: icon, color: color, budget_cents: budget && budget * 100)
        end
      end
      approver = Participant.director_logistica.find_by(gender: "M") || Participant.director_logistica.first
      director = Participant.director.first
      areas = LogisticsArea.all.index_by { |area| ImportRowEvaluator.normalize(area.name) }

      EXPENSES.each_with_index do |(concept, category, area_name, vendor, estimated, stage, actual), index|
        area = area_name && areas[ImportRowEvaluator.normalize(area_name)]
        presenter = (area && area.members.first) || Participant.logistica.first
        expense = Expense.create!(concept: concept, vendor: vendor, expense_category: ExpenseCategory.find_by(name: category),
                                  logistics_area: area, estimated_cents: estimated * 100, planned_on: Date.current + 10 + index * 7,
                                  presented_by: presenter, presented_by_name: presenter.full_name)
        case stage
        when :rejected
          expense.reject(approver, "Se van a pedir prestados a la estaca; no hace falta comprarlos.")
        when :approved
          expense.approve(approver)
        when :justification_pending, :consolidated
          expense.approve(approver)
          expense.justify(presenter, text: "El proveedor entregó la factura en físico; queda en el archivo de finanzas.",
                          actual_cents: actual * 100, spent_on: Date.current - index, payment_method: index.even? ? "transferencia" : "efectivo")
          expense.approve_justification(director) if stage == :consolidated
        end
        raise "No se pudo dejar «#{concept}» en #{stage}: #{expense.errors.full_messages.to_sentence}" unless expense.status == stage.to_s
      end
      @log.call "✔ Finanzas: #{Expense.count} gastos en #{ExpenseCategory.count} categorías"
    end

    # Unas cuantas, de la agenda y fuera de ella, para que los perfiles no se vean vacíos. Sin alerta: las
    # alertas las manda la app al asignar.
    def create_assignments
      coordinator = Participant.coordinador.first
      assigner = { assigned_by: coordinator, assigned_by_name: coordinator&.full_name || "Administrador del sistema" }
      activity = ->(title) { Activity.find_by!(title: title) }
      jovenes = Participant.joven.order(:code).to_a

      Assignment.create!(participant: jovenes[0], activity: activity.("Devocional de apertura"), status: :confirmada,
                         details: "Primera oración. Llega diez minutos antes con tu consejero.", **assigner)
      Assignment.create!(participant: jovenes[1], activity: activity.("Devocional de apertura"), status: :pendiente,
                         details: "Última oración.", **assigner)
      jovenes[2, 3].each_with_index do |joven, index|
        Assignment.create!(participant: joven, activity: activity.("Noche de talentos"), status: :pendiente,
                           details: "Presentación #{index + 1} de la noche.", **assigner)
      end
      Participant.consejero.order(:code).first(4).each_with_index do |counselor, index|
        Assignment.create!(participant: counselor, activity: activity.("Olimpiadas FSY"), status: :confirmada,
                           details: "Juez de la estación #{index + 1}.", **assigner)
      end
      Participant.logistica.joins(:logistics_area).merge(LogisticsArea.where(checkin: true)).first(2).each do |member|
        Assignment.create!(participant: member, activity: activity.("Llegada y registro"), status: :confirmada,
                           details: "Mesa de registro de la estaca Bello Horizonte.", **assigner)
      end
      Participant.auxiliar.order(:code).first(2).each do |auxiliar|
        Assignment.create!(participant: auxiliar, title: "Revisar los cuartos antes de la llegada", status: :pendiente,
                           starts_at: Rails.configuration.x.event_start_on.in_time_zone.change(hour: 7), location: "Cuartos",
                           details: "Que cada cuarto tenga sus camas y su lista pegada en la puerta.", **assigner)
      end
      @log.call "✔ Asignaciones: #{Assignment.count}"
    end
end
