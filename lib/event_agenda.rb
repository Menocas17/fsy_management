# La agenda de ejemplo de los seis días del evento, de 7:00 (desayuno) a 21:30 (devocional con consejeros),
# como suele ser una semana de FSY: clases por la mañana, tiempo de compañía, una actividad distinta cada tarde
# y cada noche, y las tres comidas. La usan los datos de prueba (EventSeed) y los de demo (DemoSeed).
#
# Borra la agenda que hubiera (y con ella sus responsables) antes de crearla.
class EventAgenda
  MEALS = [
    [ "07:00", "07:45", "Desayuno", :comida, "Comedores" ],
    [ "12:00", "13:00", "Almuerzo", :comida, "Comedores" ],
    [ "18:00", "19:00", "Cena", :comida, "Comedores" ]
  ].freeze

  COUNSELOR_DEVOTIONAL = [ "21:00", "21:30", "Devocional con consejeros", :devocional, "Cuartos de cada compañía" ].freeze

  # Lo que se repite de martes a viernes, además de las comidas y el devocional de la noche.
  DAILY = [
    [ "08:00", "08:30", "Devocional de la mañana", :devocional, "Auditorio" ],
    [ "08:45", "11:45", "Clases FSY", :clase, "Aulas 1-6" ],
    [ "13:15", "14:15", "Tiempo de compañía", :clase, "Salones de compañía" ]
  ].freeze

  # Lo propio de cada día: el primero, los de en medio (se repiten si el evento fuera más largo) y el último.
  DAYS = [
    [ [ "08:00", "10:30", "Llegada y registro", :especial, "Entrada principal" ],
      [ "10:45", "11:45", "Sesión de bienvenida", :especial, "Auditorio" ],
      [ "13:15", "14:45", "Conoce a tu compañía", :actividad, "Salones de compañía" ],
      [ "15:00", "17:30", "Clases FSY", :clase, "Aulas 1-6" ],
      [ "19:15", "20:45", "Devocional de apertura", :devocional, "Auditorio" ] ],
    [ [ "14:30", "16:30", "Olimpiadas FSY", :actividad, "Canchas" ],
      [ "16:45", "17:45", "Ensayo del coro FSY", :clase, "Auditorio" ],
      [ "19:15", "20:45", "Baile FSY", :actividad, "Gimnasio" ] ],
    [ [ "14:30", "16:30", "Talleres de talentos", :clase, "Aulas 1-6" ],
      [ "16:45", "17:45", "Tiempo personal y llamadas a casa", :actividad, "Cuartos" ],
      [ "19:15", "20:45", "Devocional del tema FSY", :devocional, "Auditorio" ] ],
    [ [ "14:30", "16:30", "Gymkana por compañías", :actividad, "Explanada" ],
      [ "16:45", "17:45", "Ensayo del coro FSY", :clase, "Auditorio" ],
      [ "19:15", "20:45", "Noche de talentos", :especial, "Auditorio" ] ],
    [ [ "14:30", "16:30", "Proyecto de compañía", :actividad, "Salones de compañía" ],
      [ "16:45", "17:45", "Fotografía por compañías", :actividad, "Explanada" ],
      [ "19:15", "20:45", "Reunión de testimonios", :especial, "Auditorio" ] ],
    [ [ "08:00", "09:30", "Sesión de clausura", :devocional, "Auditorio" ],
      [ "09:45", "11:15", "Entrega de cuartos y despedida de compañía", :actividad, "Cuartos" ],
      [ "11:30", "12:30", "Almuerzo", :comida, "Comedores" ],
      [ "12:45", "14:00", "Salida y entrega a los padres", :especial, "Entrada principal" ] ]
  ].freeze

  # Notas por rol de las actividades que más se coordinan.
  NOTES = {
    "Llegada y registro" => {
      description: "Cada joven pasa por la mesa de su estaca, recibe su gafete y su camiseta y lo lleva su consejero al cuarto.",
      logistics_notes: "Mesas de registro listas a las 7:30 con los escáneres cargados. Camisetas separadas por talla.",
      counselors_notes: "Esperen a sus jóvenes junto a la mesa de su compañía y llévenlos al cuarto en grupo.",
      youth_notes: "Trae tu autorización firmada y tu cédula o partida de nacimiento."
    },
    "Olimpiadas FSY" => {
      description: "Relevos, fútbol, voleibol y juegos de equipo entre compañías.",
      logistics_notes: "Agua y suero oral en cada cancha. Enfermería con un botiquín en el lugar.",
      counselors_notes: "Cada compañía lleva su bandera; pasen lista antes de salir y al volver.",
      youth_notes: "Ropa deportiva, tenis, gorra y bloqueador."
    },
    "Baile FSY" => {
      logistics_notes: "Sonido probado a las 17:00. Luces del gimnasio en modo baile.",
      counselors_notes: "Vestimenta de domingo modesta. Los consejeros se reparten por el gimnasio.",
      youth_notes: "Ropa de domingo y zapatos cómodos."
    },
    "Noche de talentos" => {
      description: "Los números que las compañías prepararon en los talleres de talentos.",
      logistics_notes: "Micrófonos, proyector y la lista de números impresa. Ensayo general a las 17:00.",
      counselors_notes: "Cada compañía presenta como máximo un número de 4 minutos."
    },
    "Reunión de testimonios" => {
      counselors_notes: "Se reúnen por compañía en el auditorio. Ayuden a que todos los que quieran participar lo hagan.",
      youth_notes: "Ven preparado para compartir lo que aprendiste esta semana."
    },
    "Salida y entrega a los padres" => {
      logistics_notes: "Lista de quién recoge a cada joven en la entrada. Nadie sale sin que lo firme su consejero.",
      counselors_notes: "Entreguen a cada joven a la persona autorizada y márquenlo en la lista."
    }
  }.freeze

  # Los de la dirección son responsables de los devocionales y de lo especial.
  HOSTED = %i[devocional especial].freeze

  def initialize(hosts: [])
    @hosts = hosts.compact
  end

  def create
    Activity.destroy_all
    days = Activity.event_days.to_a
    days.each_with_index do |day, index|
      last = index == days.size - 1
      slots = if index.zero? then DAYS.first
      elsif last then DAYS.last
      else DAYS[1..-2][(index - 1) % (DAYS.size - 2)] + DAILY
      end
      slots += last ? [ MEALS.first ] : MEALS + [ COUNSELOR_DEVOTIONAL ]
      slots.sort_by(&:first).each { |slot| activity(day, *slot) }
    end
    Activity.count
  end

  private
    def activity(day, start_time, end_time, title, category, location)
      record = Activity.create!(title: title, category: category, location: location, date: day.to_s,
                                start_time: start_time, end_time: end_time, **NOTES.fetch(title, {}))
      record.responsibles << @hosts if HOSTED.include?(category)
      record
    end
end
