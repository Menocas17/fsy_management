# Rebuilds the FSY 2026 demo dataset: 22 numbered companies under 5 auxiliary companies with their staff,
# the leadership, the logistics team by area, ~440 jóvenes with full profiles, and a demo login per role.
#
# Destructive: it first deletes every participant (and their photos), company, auxiliary company,
# membership, logistics area and audit log entry. User accounts are kept and re-linked.
class DemoSeed
  DEMO_PASSWORD = "FsyDemo2026!".freeze
  OWNER_EMAIL = "josmenocal@outlook.com".freeze
  OWNER_COMPANY = 3

  AUXILIAR_COMPANIES = {
    "Auxiliar Alfa" => 1..5, "Auxiliar Beta" => 6..10, "Auxiliar Gamma" => 11..14,
    "Auxiliar Delta" => 15..18, "Auxiliar Épsilon" => 19..22
  }.freeze

  # Companies 9, 15 and 21 haven't chosen a name yet.
  NICKNAMES = {
    1 => "Luz del Mundo", 2 => "Firmes y Adelante", 3 => "Guerreros de Helamán", 4 => "Sal de la Tierra",
    5 => "Roca Firme", 6 => "Hijos de la Promesa", 7 => "Valientes de Sion", 8 => "Faro de Esperanza",
    10 => "Semillas de Fe", 11 => "Ejército de Helamán", 12 => "Corazones Dispuestos", 13 => "Sendero Estrecho",
    14 => "Barra de Hierro", 16 => "Llamados a Servir", 17 => "Luces en la Colina", 18 => "Pioneros del Caribe",
    19 => "Voces de Fe", 20 => "Generación Escogida", 22 => "Unidos en Cristo"
  }.freeze

  LOGISTICS_AREAS = {
    "Finanzas" => [ 3, "Presupuesto, compras y rendición de cuentas." ],
    "Tecnología" => [ 3, "Registro digital, equipos y conectividad." ],
    "Decoración" => [ 2, "Ambientación de salones y escenario." ],
    "Alimentación" => [ 2, "Coordinación de comidas con los salones." ],
    "Transporte" => [ 2, "Buses, horarios de llegada y salida." ],
    "Salud" => [ 2, "Primeros auxilios y control de medicamentos." ],
    "Registro" => [ 2, "Check-in de participantes y credenciales." ],
    "Música y audiovisuales" => [ 2, "Sonido, proyección y ensayos musicales." ]
  }.freeze

  # The app doesn't record which ward belongs to which stake yet; adjust this mapping if it's off.
  WARDS_BY_STAKE = {
    "bello_horizonte" => %w[bello_horizonte_b la_rotonda],
    "las_americas" => %w[ciudad_jardin la_maximo_jerez],
    "villa_flor" => %w[ducuali primavera],
    "puerto_cabezas" => %w[waspan]
  }.freeze

  MALE_NAMES = %w[
    Carlos Pedro José Alejandro Mateo Daniel Gabriel Samuel David Lucas Juan Francisco Mauricio Eduardo Santiago
    Andrés Diego Fernando Ricardo Jorge Luis Miguel Óscar Julio Esteban Emilio Sebastián Tomás Adrián Kevin
    Joel Isaac Benjamín Rafael Ernesto Álvaro Marvin Byron Elías Nicolás
  ].freeze
  FEMALE_NAMES = %w[
    María Lucía Sofía Valeria Gabriela Camila Daniela Elena Victoria Sara Adriana Fernanda Paola Renata Jimena
    Andrea Carolina Mariana Isabella Natalia Ana Patricia Melissa Karla Ximena Alejandra Diana Rebeca Abigail Keyla
    Julieta Noemí Raquel Esther Tatiana Scarleth Fátima Valentina Allison Ruth
  ].freeze
  LAST_NAMES = %w[
    Gómez Méndez Pérez Rodríguez López Martínez González Hernández García Flores Sánchez Ramírez Torres Díaz Cruz
    Morales Reyes Castillo Ortiz Rivas Vega Jiménez Mendoza Espinoza Aguilar Zamora Guzmán Solís Delgado Ruiz
    Chavarría Obando Lacayo Cajina Membreño Somarriba Úbeda Picado Bermúdez Largaespada
  ].freeze

  ALLERGIES = [ "Penicilina", "Polen", "Mariscos", "Maní", "Lactosa", "Polvo" ].freeze
  MEDICINES = [ "Loratadina (según necesidad)", "Inhalador para asma", "Ibuprofeno (según necesidad)", "Vitaminas diarias" ].freeze
  DIETS = [ "Vegetariana", "Sin gluten", "Sin lactosa" ].freeze
  MEDICAL_NOTES = [ "Usa lentes de contacto.", "Asma leve; lleva su inhalador.", "Se marea en viajes largos.", "Necesita hidratarse con frecuencia." ].freeze
  JOVEN_NOTES = [
    "Primera vez en FSY.", "Llega un día después por compromisos escolares.", "Toca guitarra; puede apoyar en la música.",
    "Sus padres lo recogerán el último día.", "Prefiere actividades al aire libre."
  ].freeze
  YOUTH_RELATIONS = { "Madre" => "M", "Padre" => "H", "Tutora" => "M", "Abuela" => "M" }.freeze
  ADULT_RELATIONS = { "Madre" => "M", "Padre" => "H", "Hermana" => "M", "Hermano" => "H", "Esposa" => "M", "Esposo" => "H" }.freeze

  def initialize(out: $stdout, seed: 2026)
    @out = out
    @rng = Random.new(seed)
    @used_names = Set.new
    @email_count = 0
    @demo = {}
    @logins = []
  end

  def run
    if Rails.env.production? && ENV["ALLOW_DEMO_SEED"] != "1"
      raise "DemoSeed borra todos los participantes. Para ejecutarlo en producción usa ALLOW_DEMO_SEED=1."
    end

    ActiveRecord::Base.transaction do
      wipe!
      create_directors
      coordinators = create_coordinators
      create_logistics
      create_companies(coordinators)
      create_agenda
      create_assignments
      create_inventories
      link_logins
    end
    report
  end

  private
    def wipe!
      log "Limpiando datos anteriores…"
      AuditLog.delete_all
      # destroy, not delete: alerts purge their images and activities release their responsibles.
      Alert.destroy_all
      Assignment.delete_all
      Activity.destroy_all
      Membership.delete_all
      User.where.not(participant_id: nil).update_all(participant_id: nil)
      # companies → auxiliary companies → participants reference each other, so break the links before deleting.
      Participant.where.not(company_id: nil).update_all(company_id: nil)
      Company.delete_all
      AuxiliarCompany.delete_all
      # destroy (not delete) so Active Storage also purges their photos.
      Participant.find_each(&:destroy!)
      LogisticsArea.delete_all
      InventoryMovement.delete_all
      InventoryItem.delete_all
      Inventory.delete_all
    end

    def create_directors
      husband = person(rol: "director", gender: "H", ages: 50..60, stake: "bello_horizonte")
      wife = person(rol: "director", gender: "M", ages: 48..58, stake: "bello_horizonte",
                    emergency_contact_name: husband.full_name, emergency_contact_number: husband.phone_number, emergency_contact_relation: "Esposo")
      husband.update!(emergency_contact_name: wife.full_name, emergency_contact_number: wife.phone_number, emergency_contact_relation: "Esposa")
      @demo["director"] = husband
    end

    def create_coordinators
      coordinators = %w[H M].map { |gender| person(rol: "coordinador", gender: gender, ages: 34..50) }
      @demo["coordinador"] = coordinators.first
      coordinators
    end

    def create_logistics
      @demo["director-logistica"] = person(rol: "director_logistica", gender: pick(%w[H M]), ages: 40..55)

      LOGISTICS_AREAS.each do |name, (members, description)|
        area = LogisticsArea.create!(name: name, description: description)
        members.times do |index|
          member = person(rol: "logistica", gender: index.even? ? "M" : "H", ages: 20..55, logistics_area: area)
          @demo["logistica"] ||= member
        end
      end
    end

    def create_companies(coordinators)
      AUXILIAR_COMPANIES.each do |name, numbers|
        auxiliar_company = AuxiliarCompany.create!(name: name, coordinator: coordinators.first, second_coordinator: coordinators.last)
        %w[H M].each do |gender|
          auxiliar = person(rol: "auxiliar", gender: gender, ages: 22..35)
          auxiliar_company.memberships.create!(participant: auxiliar)
          @demo["auxiliar"] ||= auxiliar
        end
        numbers.each { |number| create_company(number, auxiliar_company) }
      end
    end

    def create_company(number, auxiliar_company)
      company = Company.create!(
        number: number, name: "Compañía #{number}", nickname: NICKNAMES[number], auxiliar_company: auxiliar_company,
        dining_hall: number <= 11 ? :salon_nicaragua : :salon_las_americas
      )

      counselors = %w[H M].to_h do |gender|
        counselor = number == OWNER_COMPANY && gender == "H" ? create_owner : person(rol: "consejero", gender: gender, ages: 19..28)
        company.memberships.create!(participant: counselor)
        [ gender, counselor ]
      end
      @demo["consejero"] ||= counselors["M"]

      create_jovenes(company, counselors)
    end

    # Boys and girls get separate rooms of up to 5; each counselor sleeps in the first room of their gender.
    def create_jovenes(company, counselors)
      total = @rng.rand(18..22)
      sizes = { "H" => (total / 2.0).ceil, "M" => total / 2 }
      room_index = 0

      sizes.each do |gender, size|
        size.times.each_slice(5) do |slice|
          room_index += 1
          room = format("%d%02d", company.number, room_index)
          counselors[gender].update!(room: room) if slice.first.zero?

          slice.size.times do
            joven = person(rol: "joven", gender: gender, ages: 14..18, company: company, room: room,
                           m_person_in_charge: counselors["M"].full_name, h_person_in_charge: counselors["H"].full_name,
                           additional_instructions: chance(0.15) ? pick(JOVEN_NOTES) : nil)
            @demo["joven"] ||= joven
          end
        end
      end
    end

    # Five days of agenda: a daily backbone of meals and devotionals plus the activity that defines each day.
    def create_agenda
      hosts = [ @demo["director"], @demo["coordinador"] ].compact
      days = agenda_days

      days.each_with_index do |(day, midday, evening), index|
        closing_day = index == days.size - 1
        activity(day, "07:00", "08:00", "Desayuno", :comida, "Comedores")
        activity(day, *midday, hosts: hosts)
        unless closing_day
          activity(day, "08:30", "09:50", "Devocional", :devocional, "Auditorio", hosts: hosts)
          activity(day, "12:30", "13:30", "Almuerzo", :comida, "Comedores")
          activity(day, "14:00", "15:50", "Clases FSY", :clase, "Aulas 1-6")
          activity(day, "18:00", "19:00", "Cena", :comida, "Comedores")
        end
        activity(day, *evening, hosts: hosts)
      end

      Activity.find_by(title: "Servicio comunitario")&.update!(
        description: "Pintura y limpieza del parque comunitario. Las compañías se dividen en cuatro frentes de trabajo.",
        logistics_notes: "30 galones de pintura, 40 brochas y 6 bidones de agua. Montaje 8:00 a.m. · 5 buses · enfermería en sitio.",
        counselors_notes: "Participan las compañías 1 a 11. Pasar lista antes de abordar; cada compañía lleva su bandera y botiquín.",
        youth_notes: "Ropa que se pueda manchar, gorra y botella de agua. Salida puntual a las 10:00."
      )
    end

    # The six days of the event, taken from the dates the app counts down to.
    def agenda_days
      first_day = Rails.configuration.x.event_start_on

      [
        [ first_day,
          [ "10:00", "12:00", "Talleres por compañía", :clase, "Aulas 1-6" ],
          [ "19:30", "21:30", "Noche de talentos", :especial, "Auditorio" ] ],
        [ first_day + 1,
          [ "10:00", "12:30", "Servicio comunitario", :servicio, "Barrio La Rotonda" ],
          [ "19:30", "21:30", "Baile FSY", :actividad, "Gimnasio" ] ],
        [ first_day + 2,
          [ "10:00", "12:00", "Clases FSY", :clase, "Aulas 1-6" ],
          [ "19:30", "21:00", "Devocional nocturno", :devocional, "Auditorio" ] ],
        [ first_day + 3,
          [ "10:00", "12:00", "Olimpiadas FSY", :actividad, "Canchas" ],
          [ "19:30", "21:30", "Fogata y testimonios", :especial, "Explanada" ] ],
        [ first_day + 4,
          [ "10:00", "12:00", "Talleres electivos", :clase, "Aulas 1-6" ],
          [ "19:30", "22:00", "Noche de gala", :especial, "Salón principal" ] ],
        [ first_day + 5,
          [ "09:00", "10:30", "Sesión de clausura", :devocional, "Auditorio" ],
          [ "13:00", "14:00", "Despedida y salida", :especial, "Explanada" ] ]
      ]
    end

    # A few assignments so the profiles don't look empty; the alerts for these go out from the app itself.
    def create_assignments
      service = Activity.find_by(title: "Servicio comunitario")
      talents = Activity.find_by(title: "Noche de talentos")
      assigner = @demo["coordinador"]
      assigner_name = assigner&.full_name || "Administrador del sistema"
      jovenes = Participant.joven.order(:first_name, :last_name).limit(3).to_a

      jovenes.each_with_index do |joven, index|
        Assignment.create!(participant: joven, activity: service, assigned_by: assigner, assigned_by_name: assigner_name,
                           status: index.zero? ? :confirmada : :pendiente,
                           details: "Frente de trabajo #{index + 1}: pintura del parque.")
      end

      Assignment.create!(participant: jovenes.first, assigned_by: assigner, assigned_by_name: assigner_name,
                         title: "Primera oración en el devocional", status: :confirmada,
                         starts_at: Time.zone.local(agenda_days.first.first.year, 1, 12, 8, 30), location: "Auditorio",
                         details: "Llega diez minutos antes con el consejero de tu compañía.")

      Assignment.create!(participant: @owner, activity: talents, assigned_by: assigner, assigned_by_name: assigner_name,
                         status: :pendiente, details: "Presentar a los grupos y cuidar los tiempos entre números.")
    end

    def activity(day, start_time, end_time, title, category, location, hosts: [])
      record = Activity.create!(title: title, category: category, location: location,
                                date: day.to_s, start_time: start_time, end_time: end_time)
      hosts.each { |host| record.responsibles << host }
      record
    end

    # Inventarios de ejemplo con algo de historial, para que el módulo no se vea vacío.
    INVENTORY_DEMO = {
      "Materiales" => { icon: "package", color: "primary", description: "Camisetas, manillas, papelería",
        items: [ [ "Camisetas talla M", "u", 50, 248 ], [ "Camisetas talla L", "u", 50, 180 ],
                 [ "Manillas de tela", "u", 80, 62 ], [ "Cuadernos FSY", "u", 100, 460 ],
                 [ "Marcadores permanentes", "u", 12, 0 ], [ "Gafetes", "u", 60, 470 ] ] },
      "Comida" => { icon: "utensils", color: "amber", description: "Refrigerios y bebidas",
        items: [ [ "Botellas de agua 600ml", "u", 200, 1240 ], [ "Galletas", "cajas", 10, 34 ],
                 [ "Jugos", "cajas", 15, 8 ], [ "Café", "libras", 5, 22 ] ] },
      "Medicinas" => { icon: "pill", color: "rose", description: "Botiquín y enfermería",
        items: [ [ "Acetaminofén 500mg", "tabletas", 100, 480 ], [ "Suero oral", "sobres", 40, 36 ],
                 [ "Curitas", "cajas", 6, 14 ], [ "Alcohol gel", "litros", 4, 9 ] ] },
      "Decoración" => { icon: "sparkles", color: "indigo", description: "Escenario y salones",
        items: [ [ "Telas de fondo", "metros", 20, 85 ], [ "Globos", "bolsas", 10, 26 ],
                 [ "Luces LED", "u", 8, 18 ] ] }
    }.freeze

    def create_inventories
      staff = Participant.where(rol: [ :logistica, :director_logistica ]).to_a

      INVENTORY_DEMO.each do |name, data|
        inventory = Inventory.create!(name: name, icon: data[:icon], color: data[:color], description: data[:description])

        data[:items].each do |item_name, unit, minimum, quantity|
          item = inventory.items.create!(name: item_name, unit: unit, minimum: minimum,
                                         location: "Bodega #{rand(1..3)}")
          next if quantity.zero?

          # Una compra inicial y, a veces, una entrega: así el historial tiene de dónde agarrarse.
          item.adjust!(delta: quantity + 20, participant: pick(staff), reason: :inicial)
          item.adjust!(delta: -20, participant: pick(staff), reason: :entrega) if staff.any?
        end
      end
    end

    def create_owner
      @used_names << "Rodolfo Jose Menocal Castillo"
      @owner = Participant.create!(profile_attributes(rol: "consejero", gender: "H", age: 25, stake: "bello_horizonte")
        .merge(first_name: "Rodolfo Jose", last_name: "Menocal Castillo", ward: "bello_horizonte_b", email_address: OWNER_EMAIL))
    end

    def person(rol:, gender:, ages:, stake: nil, **attributes)
      first_name, last_name = unique_name(gender)
      base = profile_attributes(rol: rol, gender: gender, age: @rng.rand(ages), stake: stake || pick(WARDS_BY_STAKE.keys))
      Participant.create!(base.merge(first_name: first_name, last_name: last_name,
                                     email_address: email_for(first_name, last_name)).merge(attributes))
    end

    def profile_attributes(rol:, gender:, age:, stake:)
      relations = rol == "joven" ? YOUTH_RELATIONS : ADULT_RELATIONS
      relation = pick(relations.keys)
      contact_first_name, = unique_name(relations[relation], register: false)

      {
        rol: rol, gender: gender, age: age, stake: stake, ward: pick(WARDS_BY_STAKE.fetch(stake)),
        shirt_number: pick(gender == "H" ? %w[s m m l l xl] : %w[xs s s m m l]),
        identity_document: @rng.rand(100_000_000..999_999_999),
        date_of_inscription: Date.new(2026, 1, 15) + @rng.rand(0..120),
        phone_number: phone,
        emergency_contact_name: "#{contact_first_name} #{pick(LAST_NAMES)}",
        emergency_contact_number: phone,
        emergency_contact_relation: relation,
        allergies: chance(0.2) ? pick(ALLERGIES) : "Ninguna",
        medicines: chance(0.15) ? pick(MEDICINES) : "Ninguna",
        diet: chance(0.12) ? pick(DIETS) : "Sin restricciones",
        additional_medical_notes: chance(0.1) ? pick(MEDICAL_NOTES) : nil
      }
    end

    def link_logins
      link_user(OWNER_EMAIL, @owner)
      @demo.each { |role, participant| link_user("demo.#{role}@example.com", participant) }
    end

    def link_user(email, participant)
      user = User.find_or_initialize_by(email_address: email)
      created = user.new_record?
      user.password = DEMO_PASSWORD if created
      user.update!(participant: participant)
      @logins << [ email, participant, created ]
    end

    def report
      log "✔ #{Company.count} compañías en #{AuxiliarCompany.count} compañías auxiliares"
      log "✔ #{Participant.joven.count} jóvenes, #{Participant.consejero.count} consejeros, #{Participant.auxiliar.count} auxiliares"
      log "✔ #{Participant.director.count} directores y #{Participant.coordinador.count} coordinadores"
      log "✔ Logística: #{Participant.director_logistica.count} director(a) y #{Participant.logistica.count} miembros en #{LogisticsArea.count} áreas"
      log "✔ Agenda: #{Activity.count} actividades del #{Rails.configuration.x.event_start_on.day} al #{Rails.configuration.x.event_end_on.day} de enero, con #{Assignment.count} asignaciones"
      log "✔ Inventario: #{InventoryItem.count} artículos en #{Inventory.count} inventarios, con #{InventoryMovement.count} movimientos"
      log "Cuentas (las nuevas usan la contraseña #{DEMO_PASSWORD}):"
      @logins.each do |email, participant, created|
        log "  #{email} → #{participant.full_name} (#{participant.role_label})#{' · ya existía, contraseña sin cambios' unless created}"
      end
    end

    def unique_name(gender, register: true)
      loop do
        first_name = pick(gender == "H" ? MALE_NAMES : FEMALE_NAMES)
        last_name = "#{pick(LAST_NAMES)} #{pick(LAST_NAMES)}"
        next if register && !@used_names.add?("#{first_name} #{last_name}")

        return [ first_name, last_name ]
      end
    end

    def email_for(first_name, last_name)
      @email_count += 1
      slug = ->(text) { I18n.transliterate(text.split.first).downcase.gsub(/[^a-z]/, "") }
      "#{slug.(first_name)}.#{slug.(last_name)}#{@email_count}@example.com"
    end

    def phone
      "+505 #{@rng.rand(5700..8999)} #{format('%04d', @rng.rand(0..9999))}"
    end

    def pick(list)
      list.sample(random: @rng)
    end

    def chance(probability)
      @rng.rand < probability
    end

    def log(message)
      @out.puts(message)
    end
end
