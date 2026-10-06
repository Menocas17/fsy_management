require "roo"

# Deja la base como si el evento ya estuviera armado, con las personas de los archivos de prueba
# (docs/cargas_de_prueba): primero hace lo mismo que `datos:reiniciar` (EventReset) y luego crea las 25
# compañías en sus 5 compañías auxiliares, la dirección, la logística en sus áreas, los 50 consejeros en su
# compañía y los 512 jóvenes repartidos en las compañías y en sus cuartos. Después llena los demás módulos
# (EventSeed::Operations): agenda, inventarios, capacitaciones, finanzas y asignaciones. Lo corre
# `bin/rails datos:sembrar`.
#
# No crea superadmins, cuentas ni áreas de logística: los superadmins se quedan (sin ficha) y la logística
# entra en las áreas que ya existen, buscadas por nombre como en la carga masiva (Finanzas, Registro,
# Alimentación, Enfermería). Quien trae un área que no existe queda sin área.
class EventSeed
  FILES = Rails.root.join("docs/cargas_de_prueba")
  COMPANIES_FILE = FILES.join("1_companias.xlsx")
  LEADERSHIP_FILE = FILES.join("2_direccion_y_logistica.xlsx")
  COUNSELORS_FILE = FILES.join("3_consejeros.xlsx")
  JOVENES_FILE = FILES.join("4_jovenes.xlsx")

  DINING_HALLS = { "salon nicaragua" => "salon_nicaragua", "salon las americas" => "salon_las_americas" }.freeze
  ROOM_SIZE = 5

  # Las áreas que nombran los archivos y no existen: sin ellas, esa logística queda sin área (y sin sus permisos).
  def self.missing_areas
    wanted = ParticipantImporter.new(LEADERSHIP_FILE.to_s).rows.filter_map { |_, values| values[:logistics_area] }.uniq
    existing = LogisticsArea.pluck(:name).map { |name| ImportRowEvaluator.normalize(name) }
    wanted.reject { |name| existing.include?(ImportRowEvaluator.normalize(name)) }
  end

  def initialize(out: $stdout)
    @out = out
  end

  def run
    ActiveRecord::Base.transaction do
      log "Borrando los datos anteriores…"
      EventReset.new(out: StringIO.new).run
      companies = create_companies
      log "✔ #{companies.size} compañías en #{AuxiliarCompany.count} compañías auxiliares"
      create_leadership
      counselors = create_counselors(companies)
      create_jovenes(companies, counselors)
      Operations.new(log: method(:log)).run
      AuditLog.create!(actor_name: "Administrador del sistema", action: "created", category: :participantes,
                       summary: "Cargó los datos de prueba: #{Participant.count} fichas en #{Company.count} compañías")
    end
    report
  end

  private
    def create_companies
      sheet = Roo::Spreadsheet.open(COMPANIES_FILE.to_s).sheet(0)
      (2..sheet.last_row).filter_map do |number|
        company_number, auxiliar_name, dining_hall = sheet.row(number)
        next if company_number.blank?

        auxiliar_company = AuxiliarCompany.find_or_create_by!(name: auxiliar_name.to_s.strip)
        Company.create!(number: company_number.to_i, auxiliar_company: auxiliar_company,
                        dining_hall: DINING_HALLS[ImportRowEvaluator.normalize(dining_hall)])
      end.index_by(&:number)
    end

    # Dirección, coordinación, dirección de logística, auxiliares y logística: el rol lo dice la columna Rol.
    def create_leadership
      people = rows(LEADERSHIP_FILE).map { |values| [ build(values), values ] }
      people.each { |participant, _| participant.save! }

      people.each do |participant, values|
        next unless participant.auxiliar?

        auxiliar_company = auxiliar_company_named(values[:auxiliar_company])
        auxiliar_company.memberships.create!(participant: participant) if auxiliar_company
      end

      log "✔ Dirección: #{Participant.director.count} directores, #{Participant.coordinador.count} coordinadores, " \
          "#{Participant.director_logistica.count} directores de logística"
      log "✔ #{Participant.auxiliar.count} auxiliares, #{Membership.where(associable_type: "AuxiliarCompany").count} en su compañía auxiliar"
      log "✔ Logística: #{Participant.logistica.count} personas, #{Participant.logistica.where.not(logistics_area_id: nil).count} con su área"
    end

    # La «Compañía» de la ficha del consejero crea su lugar en el personal de la compañía (sync_counselor_membership).
    def create_counselors(companies)
      counselors = rows(COUNSELORS_FILE).map do |values|
        participant = build(values.merge(rol: "consejero"))
        participant.company = companies[values[:company_number].to_i]
        participant.tap(&:save!)
      end
      log "✔ #{counselors.size} consejeros, #{Membership.where(associable_type: "Company", role: :consejero).count} con su compañía"
      counselors.select(&:company_id).group_by(&:company_id)
    end

    # Cada compañía recibe chicos y chicas de todas las estacas y edades: por género, ordenados por estaca, barrio
    # y edad, se reparten como cartas entre las compañías. Las chicas empiezan donde terminaron los chicos, así
    # las compañías quedan parejas (20 o 21). Luego, por compañía y género, cuartos de hasta cinco, parejos; cada
    # consejero duerme en el primero de su género.
    def create_jovenes(companies, counselors)
      jovenes = rows(JOVENES_FILE).map { |values| build(values.merge(rol: "joven")) }
      list = companies.values.sort_by(&:number)
      offset = 0

      %w[H M].each do |gender|
        group = jovenes.select { |joven| joven.gender == gender }
                       .sort_by { |joven| [ joven.stake.to_s, joven.ward.to_s, joven.age.to_i, joven.full_name ] }
        group.each_with_index { |joven, index| joven.company = list[(index + offset) % list.size] }
        offset = group.size % list.size
      end

      jovenes.group_by(&:company).each do |company, members|
        room_index = 0
        %w[H M].each do |gender|
          same_gender = members.select { |joven| joven.gender == gender }
          per_room = same_gender.size.fdiv((same_gender.size / ROOM_SIZE.to_f).ceil).ceil
          same_gender.each_slice(per_room) do |room_members|
            room_index += 1
            room = format("%d%02d", company.number, room_index)
            room_members.each { |joven| joven.room = room }
            counselor = counselors.fetch(company.id, []).find { |person| person.gender == gender }
            counselor.update!(room: room) if counselor && counselor.room.blank?
          end
        end
      end

      jovenes.each_with_index do |joven, index|
        joven.save!
        log "  #{index + 1} de #{jovenes.size} jóvenes…" if ((index + 1) % 100).zero?
      end
      log "✔ #{jovenes.size} jóvenes en #{jovenes.map(&:company_id).uniq.size} compañías"
    end

    def rows(path)
      ParticipantImporter.new(path.to_s).rows.map(&:last)
    end

    def build(values)
      ImportRowEvaluator.new(values).build
    end

    def auxiliar_company_named(name)
      wanted = ImportRowEvaluator.normalize(name).delete_prefix("auxiliar ").strip
      AuxiliarCompany.all.find { |auxiliar| ImportRowEvaluator.normalize(auxiliar.name).delete_prefix("auxiliar ").strip == wanted }
    end

    def report
      jovenes = Participant.joven
      log "", "Listo: #{Participant.count} fichas."
      log "  Compañías con sus dos consejeros: #{Company.all.count(&:staff_complete?)} de #{Company.count}"
      log "  Jóvenes por compañía: #{Company.jovenes_counts.values.minmax.uniq.join(" a ")}"
      log "  Jóvenes con información médica: #{jovenes.with_medical_note(:medical_information).count}, " \
          "con dieta especial: #{jovenes.with_medical_note(:diet).count}, " \
          "con información emocional: #{jovenes.with_medical_note(:emotional_information).count}"
    end

    def log(*lines)
      lines.each { |line| @out.puts(line) }
    end
end
