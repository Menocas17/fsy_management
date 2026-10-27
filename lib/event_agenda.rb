# La agenda del evento tal como la trae el Manual del consejero FSY 2026 (Día 1 lunes a Día 5 viernes): cada día
# cae en el día del evento que le toca, del primero en adelante. No van los traslados de 5 a 20 minutos entre una
# actividad y otra (llenarían la cuadrícula de bloques sueltos), y lo que el manual pone en la misma fila a la
# misma hora va en una sola actividad. El Día 0 (domingo, solo personal) queda fuera de los días del evento.
# La usan bin/rails agenda:manual, los datos de prueba (EventSeed) y los de demo (DemoSeed).
#
# Borra la agenda que hubiera (y con ella sus responsables) antes de crearla.
class EventAgenda
  STAFF_MEETING = "Reunión de coordinadores, coordinadores auxiliares y consejeros".freeze
  NIGHT_MEETING = "Tiempo para meditar / Reunión de coordinadores y coordinadores auxiliares".freeze
  BOOK_OF_MORMON = "Estudio de El Libro de Mormón".freeze
  DANCE_REHEARSALS = "Clases de baile / Ensayo del programa musical / Ensayo del espectáculo de variedades".freeze
  MORNING_DEVOTIONAL = "Devocional matutino con el matrimonio director de sesión".freeze

  COMPANY_SPOT = "Punto de reunión de la compañía".freeze
  HALL = "Salón general".freeze
  DINING = "Comedor".freeze
  ROOMS = "Área de dormitorios".freeze

  # [inicio, fin, título, categoría, lugar], un arreglo por día del manual.
  DAYS = [
    # Día 1: lunes
    [ [ "06:00", "07:00", "Desayuno", :comida, DINING ],
      [ "07:10", "07:50", STAFF_MEETING, :actividad, nil ],
      [ "08:00", "11:15", "Recibir a los participantes y distribución de habitaciones", :especial, nil ],
      [ "11:30", "12:50", "Almuerzo / Ensayo del programa musical", :comida, DINING ],
      [ "13:00", "13:50", "Reúnete con tu consejero", :actividad, COMPANY_SPOT ],
      [ "14:00", "14:35", "Reúnete con tu compañía", :actividad, COMPANY_SPOT ],
      [ "14:35", "14:45", "Nombre y verso cantado de la compañía", :actividad, COMPANY_SPOT ],
      [ "15:00", "16:00", "Orientación", :especial, HALL ],
      [ "16:00", "16:45", "Noche de hogar", :devocional, HALL ],
      [ "17:00", "17:50", "Juegos de la noche de hogar", :actividad, nil ],
      [ "18:05", "19:25", "Cena", :comida, DINING ],
      [ "19:40", "20:10", "Establecimiento de metas", :clase, ROOMS ],
      [ "20:10", "20:55", NIGHT_MEETING, :actividad, ROOMS ],
      [ "20:55", "21:25", "Reflexiona y repasa", :devocional, ROOMS ],
      [ "21:30", "22:30", "Lectura de El Libro de Mormón", :devocional, ROOMS ] ],
    # Día 2: martes
    [ [ "05:00", "05:45", STAFF_MEETING, :actividad, nil ],
      [ "05:45", "06:00", "Devocional matutino del participante", :devocional, COMPANY_SPOT ],
      [ "06:00", "07:45", "Desayuno / Limpieza personal", :comida, DINING ],
      [ "08:00", "08:50", "Estudio del Evangelio", :clase, COMPANY_SPOT ],
      [ "09:00", "10:00", MORNING_DEVOTIONAL, :devocional, HALL ],
      [ "10:05", "11:00", "Vivir el Evangelio", :clase, nil ],
      [ "11:00", "11:45", "Amar, compartir e invitar", :clase, nil ],
      [ "12:00", "13:20", "Almuerzo / Ensayo del programa musical", :comida, DINING ],
      [ "13:30", "14:30", "Clase", :clase, nil ],
      [ "14:30", "15:00", "Estandarte personal", :actividad, nil ],
      [ "15:15", "16:00", "Preparación del estandarte y versos cantados", :actividad, COMPANY_SPOT ],
      [ "16:00", "16:15", "Pautas para los bailes FSY", :clase, COMPANY_SPOT ],
      [ "16:30", "17:15", DANCE_REHEARSALS, :actividad, nil ],
      [ "17:30", "18:50", "Cena", :comida, DINING ],
      [ "19:00", "20:15", "Fiesta FSY", :especial, nil ],
      [ "20:30", "21:15", NIGHT_MEETING, :actividad, ROOMS ],
      [ "21:15", "21:45", "Reflexiona y repasa", :devocional, ROOMS ],
      [ "21:50", "22:30", BOOK_OF_MORMON, :devocional, ROOMS ] ],
    # Día 3: miércoles
    [ [ "04:40", "05:30", STAFF_MEETING, :actividad, nil ],
      [ "05:45", "06:00", "Devocional matutino del participante", :devocional, COMPANY_SPOT ],
      [ "06:00", "07:45", "Desayuno / Limpieza personal", :comida, DINING ],
      [ "08:00", "08:50", "Estudio del Evangelio", :clase, COMPANY_SPOT ],
      [ "09:00", "10:00", MORNING_DEVOTIONAL, :devocional, HALL ],
      [ "10:00", "10:20", "Distribución para la actividad deportiva", :actividad, nil ],
      [ "10:20", "12:00", "Actividad deportiva", :actividad, nil ],
      [ "12:00", "14:00", "Aseo personal / Almuerzo / Ensayo del programa musical / Preparación de versos cantados", :comida, DINING ],
      [ "14:10", "15:00", "Clase / Reunión de coordinadores y coordinadores auxiliares", :clase, nil ],
      [ "15:10", "16:10", DANCE_REHEARSALS, :actividad, nil ],
      [ "16:25", "18:10", "Noche de juegos, estandartes y versos cantados", :actividad, nil ],
      [ "18:25", "19:45", "Cena favorita y karaoke", :comida, DINING ],
      [ "19:55", "20:40", NIGHT_MEETING, :actividad, ROOMS ],
      [ "20:40", "21:10", "Reflexiona y repasa", :devocional, ROOMS ],
      [ "21:15", "22:30", BOOK_OF_MORMON, :devocional, ROOMS ] ],
    # Día 4: jueves
    [ [ "05:00", "05:45", STAFF_MEETING, :actividad, nil ],
      [ "05:45", "06:00", "Devocional matutino del participante", :devocional, COMPANY_SPOT ],
      [ "06:00", "07:45", "Desayuno / Limpieza personal", :comida, DINING ],
      [ "08:00", "08:50", "Estudio del Evangelio", :clase, COMPANY_SPOT ],
      [ "09:00", "10:00", MORNING_DEVOTIONAL, :devocional, HALL ],
      [ "10:10", "11:40", "Actividad de Hombres y Mujeres Jóvenes", :clase, nil ],
      [ "12:00", "13:20", "Almuerzo / Ensayo del programa musical", :comida, DINING ],
      [ "13:30", "14:30", "Clase", :clase, nil ],
      [ "14:40", "15:40", "Clase", :clase, nil ],
      [ "15:55", "16:10", "Análisis sobre la reverencia y el testimonio", :clase, COMPANY_SPOT ],
      [ "16:10", "17:20", "Tiempo libre o juegos", :actividad, nil ],
      [ "17:30", "18:50", "Cena", :comida, DINING ],
      [ "19:00", "20:20", "Programa musical y devocional con la autoridad visitante", :especial, HALL ],
      [ "20:40", "21:30", "Reunión de testimonios", :especial, nil ],
      [ "22:00", "22:30", "Reflexiona y repasa / Noche de compromisos", :devocional, ROOMS ],
      [ "22:30", "23:00", NIGHT_MEETING, :actividad, ROOMS ],
      [ "23:00", "23:30", BOOK_OF_MORMON, :devocional, ROOMS ] ],
    # Día 5: viernes
    [ [ "05:00", "05:45", STAFF_MEETING, :actividad, nil ],
      [ "05:45", "06:00", "Devocional matutino del participante", :devocional, COMPANY_SPOT ],
      [ "06:00", "07:45", "Desayuno / Limpieza personal", :comida, DINING ],
      [ "07:55", "08:45", "Estudio del Evangelio", :clase, COMPANY_SPOT ],
      [ "08:45", "09:15", "Repaso del establecimiento de metas", :clase, COMPANY_SPOT ],
      [ "09:30", "10:20", MORNING_DEVOTIONAL, :devocional, HALL ],
      [ "10:40", "11:40", "Actividad de la guía Para la Fortaleza de la Juventud", :clase, nil ],
      [ "11:55", "13:15", "Almuerzo / Ensayo del espectáculo de variedades", :comida, DINING ],
      [ "13:30", "14:45", "Espectáculo de variedades", :especial, HALL ],
      [ "14:45", "16:30", "Cambio de ropa", :actividad, ROOMS ],
      [ "16:30", "17:30", "Foto por compañía", :actividad, nil ],
      [ "17:30", "18:50", "Cena", :comida, DINING ],
      [ "18:50", "20:50", "Fiesta", :especial, nil ],
      [ "20:50", "21:00", "Llamado a la reverencia", :devocional, nil ],
      [ "21:00", "21:30", "Mensaje «Llévatelo a casa»", :especial, HALL ],
      [ "21:40", "22:10", "Mensaje «Llévatelo a casa» de la compañía", :devocional, COMPANY_SPOT ],
      [ "22:30", "23:00", BOOK_OF_MORMON, :devocional, ROOMS ] ]
  ].freeze

  # Solo el personal: los jóvenes no reciben la alerta si cambian.
  STAFF_ONLY = [ STAFF_MEETING ].freeze
  STAFF_ROLES = %w[director coordinador auxiliar consejero].freeze

  # El estudio de la noche termina cuando se apagan las luces.
  LIGHTS_OUT = [ "Lectura de El Libro de Mormón", BOOK_OF_MORMON ].freeze

  # Lo que dice el manual de cada una: quién la tiene a cargo y qué hace cada rol.
  NOTES = {
    "Desayuno" => {
      description: "Responsable: coordinador de alimentos.",
      counselors_notes: "Buen momento para comer con tu compañero y ultimar los detalles del día."
    },
    "Desayuno / Limpieza personal" => {
      description: "Responsable: consejeros y coordinador de alimentos.",
      counselors_notes: "Ayuden a los jóvenes a comportarse bien y a quedarse en las zonas autorizadas; enséñenles a dejar limpio al terminar. Sigan el horario de duchas y desayuno de su compañía y, mientras puedan, coman con ellos.",
      logistics_notes: "Comedor listo con el horario de cada compañía."
    },
    "Almuerzo / Ensayo del programa musical" => {
      description: "Responsable: coordinador de alimentos y consejeros. Los del programa musical ensayan en este tiempo.",
      counselors_notes: "Siéntense con su compañía y hagan el recuento de los jóvenes durante el almuerzo."
    },
    "Cena" => {
      description: "Responsable: coordinador de alimentos y consejeros.",
      counselors_notes: "Comer juntos es la mejor ocasión para conocer a los jóvenes. Ayuden a que se porten bien y no salgan de las zonas autorizadas."
    },
    STAFF_MEETING => {
      description: "Responsable: coordinadores. Anuncios y cambios del día, y cómo se llevarán a cabo las actividades.",
      counselors_notes: "Lleven su horario, lápiz y manual de líder, y anoten los anuncios y los cambios de horario."
    },
    "Recibir a los participantes y distribución de habitaciones" => {
      description: "Responsable: coordinadores y coordinadores auxiliares.",
      counselors_notes: "Den la bienvenida a cada joven con una primera impresión cordial y llévenlo a su habitación. Estén alerta y dispuestos a servir durante todo el registro.",
      logistics_notes: "Mesas de registro, gafetes y la lista de habitaciones listos antes de las 8:00.",
      youth_notes: "Trae tu autorización firmada."
    },
    "Reúnete con tu consejero" => {
      description: "Responsable: consejeros y coordinadores auxiliares. El primer encuentro de cada joven con su consejero.",
      counselors_notes: "Conozcan a los jóvenes, fijen las expectativas de la semana y asignen a quién le toca cada devocional matutino del participante."
    },
    "Reúnete con tu compañía" => {
      description: "Responsable: consejeros.",
      counselors_notes: "Creen un ambiente de unidad y cariño mientras los jóvenes se conocen."
    },
    "Nombre y verso cantado de la compañía" => {
      description: "Cada compañía elige su nombre y su verso cantado."
    },
    "Orientación" => {
      description: "Responsable: coordinadores. Se presenta al matrimonio director de sesión, a los coordinadores y auxiliares, y se da la información de las actividades de la semana."
    },
    "Noche de hogar" => {
      description: "Responsable: director de sesión y coordinadores. Aquí se presenta el lema anual de los jóvenes."
    },
    "Juegos de la noche de hogar" => {
      description: "Responsable: consejeros.",
      counselors_notes: "Elijan algunos juegos del manual y, después de cada uno, tomen de cinco a diez minutos para relacionarlo con los principios del Evangelio."
    },
    "Establecimiento de metas" => {
      description: "Responsable: consejeros. Cada joven fija sus metas para la semana.",
      counselors_notes: "Den seguimiento diario a las metas personales de cada joven."
    },
    NIGHT_MEETING => {
      description: "Responsable: consejeros. Los jóvenes se preparan para dormir mientras los coordinadores y coordinadores auxiliares se reúnen.",
      counselors_notes: "Dejen que los jóvenes se relajen y conversen mientras se duchan y se preparan para acostarse; desalienten el comportamiento revoltoso."
    },
    "Reflexiona y repasa" => {
      description: "Responsable: consejeros. Cada noche los jóvenes meditan sobre lo que vivieron en el día.",
      counselors_notes: "Sigan con el atuendo de la conferencia durante Reflexiona y repasa."
    },
    "Reflexiona y repasa / Noche de compromisos" => {
      description: "Responsable: consejeros. Los jóvenes meditan sobre el día y hacen sus compromisos.",
      counselors_notes: "Sigan con el atuendo de la conferencia."
    },
    "Lectura de El Libro de Mormón" => {
      description: "Cada joven lee en su habitación."
    },
    BOOK_OF_MORMON => {
      description: "Cada joven estudia en su habitación."
    },
    "Devocional matutino del participante" => {
      description: "Responsable: consejeros y participantes. Un joven de la compañía enseña un devocional breve.",
      counselors_notes: "Asignen los devocionales de toda la semana en «Reúnete con tu consejero».",
      youth_notes: "Si te toca, prepara un mensaje corto para tu compañía."
    },
    "Estudio del Evangelio" => {
      description: "Responsable: consejeros. En el punto de reunión de la compañía, para crecer en el amor por las Escrituras y el hábito del estudio diario."
    },
    MORNING_DEVOTIONAL => {
      description: "Responsable: coordinador y matrimonio director de sesión.",
      counselors_notes: "Si invitaron a jóvenes de su compañía a orar o a un número musical, que entren primero al salón."
    },
    "Vivir el Evangelio" => {
      description: "Responsable: matrimonio director de sesión, coordinadores y coordinadores auxiliares.",
      counselors_notes: "El lunes pregunten quién trajo recuerdos, historias, fotos o la tarjeta del templo de un antepasado para compartir.",
      youth_notes: "Trae algo de un antepasado tuyo (una historia, una foto) si lo tienes."
    },
    "Amar, compartir e invitar" => {
      description: "Responsable: consejeros y coordinadores auxiliares. Basada en el devocional «Juventud de Israel» del presidente Russell M. Nelson."
    },
    "Clase" => {
      description: "Responsable: coordinador auxiliar y maestros del SEI.",
      counselors_notes: "Si invitaron a jóvenes de su compañía a participar, que entren primero al salón."
    },
    "Clase / Reunión de coordinadores y coordinadores auxiliares" => {
      description: "Responsable: coordinador auxiliar. Mientras los jóvenes están en clase, los coordinadores y auxiliares se reúnen."
    },
    "Estandarte personal" => {
      description: "Responsable: coordinador auxiliar.",
      counselors_notes: "Repartan la hoja de «Estandarte personal» y quédense con los jóvenes para resolver dudas y darles ideas."
    },
    "Preparación del estandarte y versos cantados" => {
      description: "Responsable: consejeros y participantes. Cada compañía prepara su estandarte y sus versos cantados para la competencia.",
      counselors_notes: "Reciben el estandarte y los materiales en la reunión con su coordinador auxiliar."
    },
    "Pautas para los bailes FSY" => {
      description: "Responsable: consejeros. Cómo se baila en FSY y el protocolo para invitar a bailar."
    },
    DANCE_REHEARSALS => {
      description: "Responsable: coordinador auxiliar.",
      counselors_notes: "Sigan las instrucciones de su coordinador auxiliar y participen en lo que les asignen."
    },
    "Fiesta FSY" => {
      description: "Responsable: todos.",
      counselors_notes: "Hagan cumplir las normas del baile, bailen con los jóvenes y estén pendientes de quien no está siendo invitado.",
      youth_notes: "Ropa modesta y zapatos cómodos."
    },
    "Distribución para la actividad deportiva" => {
      description: "Cada compañía va a la cancha de su estaca."
    },
    "Actividad deportiva" => {
      description: "Responsable: todos.",
      counselors_notes: "Quédense con los jóvenes de la estaca asignada en todo momento y acompañen a los que jueguen hasta su cancha.",
      logistics_notes: "Canchas e implementos deportivos revisados un día antes; agua en cada cancha.",
      youth_notes: "Ropa deportiva, tenis, gorra y bloqueador."
    },
    "Aseo personal / Almuerzo / Ensayo del programa musical / Preparación de versos cantados" => {
      description: "Responsable: consejeros y coordinador de alimentos."
    },
    "Noche de juegos, estandartes y versos cantados" => {
      description: "Responsable: coordinadores auxiliares.",
      counselors_notes: "Prepárense para enseñar los juegos: pasen al frente a un par de jóvenes, muestren cómo se juega y respondan las preguntas."
    },
    "Cena favorita y karaoke" => {
      description: "Responsable: coordinador de música.",
      counselors_notes: "Siéntense con su compañía y canten con ellos."
    },
    "Actividad de Hombres y Mujeres Jóvenes" => {
      description: "«El Libro de Mormón: Otro testamento de Jesucristo». Responsable: consejeros.",
      counselors_notes: "Guíen a los jóvenes en la actividad del Manual para el participante y analicen los testigos espirituales y físicos del Libro de Mormón."
    },
    "Análisis sobre la reverencia y el testimonio" => {
      description: "Responsable: consejeros. En el punto de reunión de la compañía: un himno y Doctrina y Convenios 88:67–68.",
      counselors_notes: "Enseñen que la reverencia no es solo estar callado, sino una condición del ser."
    },
    "Programa musical y devocional con la autoridad visitante" => {
      description: "Responsable: la autoridad visitante.",
      counselors_notes: "Que los jóvenes entren con reverencia y con sus notas a la mano para escribir lo que sientan."
    },
    "Reunión de testimonios" => {
      description: "Responsable: coordinador auxiliar.",
      counselors_notes: "Comprueben que la compañía esté completa antes de ir. Animen a los jóvenes a compartir o escribir su testimonio y a permanecer reverentes.",
      youth_notes: "Ven preparado para compartir lo que aprendiste esta semana."
    },
    "Repaso del establecimiento de metas" => {
      description: "Responsable: consejeros. Los jóvenes repasan las metas que se pusieron el lunes."
    },
    "Actividad de la guía Para la Fortaleza de la Juventud" => {
      description: "Responsable: coordinador auxiliar y consejeros. Un auxiliar la presenta y los consejeros dirigen el juego y el análisis en grupo."
    },
    "Espectáculo de variedades" => {
      description: "Responsable: coordinador del espectáculo de variedades y coordinador auxiliar.",
      counselors_notes: "Quédense con su compañía y anímenla a apoyar a los jóvenes que presentan su talento.",
      logistics_notes: "Sonido, micrófonos y la lista de números listos antes de empezar."
    },
    "Mensaje «Llévatelo a casa»" => {
      description: "Responsable: matrimonio director de sesión.",
      counselors_notes: "Siéntense con los jóvenes y anímenlos a tomar notas; después les ayudarán a crear sus metas de «Llévatelo a casa»."
    },
    "Mensaje «Llévatelo a casa» de la compañía" => {
      description: "Cada compañía repasa la «Invitación a hacer y llegar a ser» y escribe sus metas para casa.",
      counselors_notes: "Esta noche hay guardia nocturna: cada consejero en su salida, escalera o edificio asignado hasta que su área esté en silencio."
    }
  }.freeze

  # Los de la dirección son responsables de los devocionales y de lo especial.
  HOSTED = %i[devocional especial].freeze

  def initialize(hosts: [])
    @hosts = hosts.compact
  end

  def create
    Activity.transaction do
      Activity.destroy_all
      Activity.event_days.first(DAYS.size).zip(DAYS).each do |day, slots|
        slots.each { |slot| activity(day, *slot) }
      end
    end
    Activity.count
  end

  private
    def activity(day, start_time, end_time, title, category, location)
      notes = NOTES.fetch(title, {})
      notes = notes.merge(description: [ notes[:description], "Se apagan las luces a las #{end_time}." ].compact.join(" ")) if LIGHTS_OUT.include?(title)
      audience = STAFF_ONLY.include?(title) ? { audience: :por_roles, target_roles: STAFF_ROLES } : {}
      record = Activity.create!(title: title, category: category, location: location, date: day.to_s,
                                start_time: start_time, end_time: end_time, **notes, **audience)
      record.responsibles << @hosts if HOSTED.include?(category)
      record
    end
end
