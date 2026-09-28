require "roo"

# Carga masiva de participantes desde un Excel. Las cabeceras se reconocen sin importar mayúsculas,
# acentos ni espacios, así que el archivo real del registro debería entrar sin retoques; si trae otras
# columnas, se agregan a HEADERS y listo.
class ParticipantImporter
  class UnreadableFile < StandardError; end

  # match: la ficha que ya existe y con la que choca la fila, para revisarla y resolver a mano.
  # record: la ficha que se creó con esa fila (en los avisos).
  Row = Struct.new(:number, :name, :reason, :match, :record, keyword_init: true)

  HEADERS = {
    "nombre" => :first_name, "nombres" => :first_name, "primer nombre" => :first_name,
    "apellido" => :last_name, "apellidos" => :last_name, "segundo nombre" => :last_name,
    "edad" => :age,
    "genero" => :gender, "sexo" => :gender,
    "estaca" => :stake,
    "barrio" => :ward, "rama" => :ward,
    "camisa" => :shirt_number, "talla" => :shirt_number, "talla de camisa" => :shirt_number,
    "rol" => :rol,
    "cedula" => :identity_document, "identificacion" => :identity_document, "documento" => :identity_document,
    "cuarto" => :room, "habitacion" => :room,
    "compania" => :company_number, "numero de compania" => :company_number,
    "compania auxiliar" => :auxiliar_company, "auxiliar asignada" => :auxiliar_company,
    "telefono" => :phone_number, "celular" => :phone_number,
    "correo" => :email_address, "email" => :email_address, "correo electronico" => :email_address,
    "contacto de emergencia" => :emergency_contact_name,
    "telefono de emergencia" => :emergency_contact_number,
    "parentesco" => :emergency_contact_relation,
    "alergias" => :allergies,
    "medicinas" => :medicines, "medicamentos" => :medicines,
    "dieta" => :diet,
    "notas" => :additional_instructions, "observaciones" => :additional_instructions
  }.freeze

  # «M» es mujer, como en la app (H/M); «F» (femenino) también, porque así vienen muchos formularios.
  GENDERS = { "h" => "H", "hombre" => "H", "masculino" => "H", "varon" => "H",
              "m" => "M", "mujer" => "M", "femenino" => "M", "f" => "M" }.freeze

  attr_reader :imported, :skipped, :warnings, :fatal

  def initialize(file)
    @file = file
    @imported = []
    @skipped = []
    # Filas que sí entraron pero conviene revisar: mismo nombre, correo o teléfono que otra persona, o
    # una compañía que no se pudo usar.
    @warnings = []
  end

  def call
    sheet = open_sheet
    headers = map_headers(sheet.row(1))
    raise UnreadableFile, "El archivo no tiene ninguna columna reconocible (revisa la primera fila)." if headers.values.none?

    Participant.transaction do
      (2..sheet.last_row).each { |number| process(sheet.row(number), headers, number) }
    end
    self
  rescue UnreadableFile => error
    @fatal = error.message
    self
  end

  def imported_count = imported.size
  def skipped_count = skipped.size

  private
    def open_sheet
      Roo::Spreadsheet.open(path_for(@file), extension: extension_for(@file)).sheet(0)
    rescue StandardError => error
      raise UnreadableFile, "No se pudo leer el archivo (#{error.class}). Sube un .xlsx o un .csv."
    end

    def path_for(file)
      file.respond_to?(:tempfile) ? file.tempfile.path : file.to_s
    end

    def extension_for(file)
      name = file.respond_to?(:original_filename) ? file.original_filename : file.to_s
      File.extname(name).delete(".").downcase.presence&.to_sym || :xlsx
    end

    # Posición de cada columna reconocida: { first_name: 0, edad: 1, ... }
    def map_headers(row)
      row.each_with_index.each_with_object({}) do |(cell, index), found|
        key = HEADERS[normalize(cell)]
        found[key] ||= index if key
      end
    end

    def normalize(value)
      value.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase.squish
    end

    def process(row, headers, number)
      values = headers.transform_values { |index| clean(row[index]) }
      name = [ values[:first_name], values[:last_name] ].compact_blank.join(" ")
      return if values.values.all?(&:blank?)

      if (existing = duplicate_of(values))
        @skipped << Row.new(number: number, name: name, reason: "duplicado: ya existe esta persona", match: existing)
        return
      end

      participant = Participant.new(attributes_for(values))
      if participant.save
        @imported << participant
        warn_about(participant, values, number, staffing_notes(participant, values))
      else
        @skipped << Row.new(number: number, name: name.presence || "sin nombre",
                            reason: participant.errors.full_messages.to_sentence)
      end
    end

    def clean(value)
      value.is_a?(String) ? value.strip.presence : value
    end

    def attributes_for(values)
      {
        first_name: values[:first_name], last_name: values[:last_name],
        age: whole_number(values[:age]), gender: GENDERS[normalize(values[:gender])],
        stake: enum_key(Participant.stakes, values[:stake]),
        ward: enum_key(Participant.wards, values[:ward]),
        shirt_number: enum_key(Participant.shirt_numbers, values[:shirt_number]),
        rol: enum_key(Participant.rols, values[:rol]) || "joven",
        identity_document: values[:identity_document].presence&.to_s,
        room: values[:room]&.to_s,
        # La compañía de un joven es la suya; el staff se asigna a una compañía desde la compañía misma.
        company_id: (staff_role?(values) ? nil : company_id_for(values[:company_number])),
        phone_number: values[:phone_number]&.to_s, email_address: values[:email_address],
        emergency_contact_name: values[:emergency_contact_name],
        emergency_contact_number: values[:emergency_contact_number]&.to_s,
        emergency_contact_relation: values[:emergency_contact_relation],
        allergies: values[:allergies], medicines: values[:medicines], diet: values[:diet],
        additional_instructions: values[:additional_instructions]
      }.compact
    end

    # "Bello Horizonte" → :bello_horizonte, "M" → :m, "Joven" → :joven.
    def enum_key(mapping, value)
      return nil if value.blank?

      needle = normalize(value).tr(" ", "_")
      mapping.keys.find { |key| key == needle || normalize(key.tr("_", " ")) == normalize(value) }
    end

    # «15», 15 o 15.0 → 15. Lo que no es número se deja tal cual, para que el error diga «debe ser un número»
    # en vez de convertirse en 0.
    def whole_number(value)
      return value.to_i if value.is_a?(Numeric)

      value.to_s.strip.match?(/\A\d+(\.0+)?\z/) ? value.to_i : value
    end

    def company_id_for(number)
      return nil if number.blank?

      @companies ||= Company.pluck(:number, :id).to_h
      @companies[number.to_s.gsub(/\D/, "").to_i]
    end

    # La cédula manda cuando viene (escrita con o sin guiones). Sin cédula, es la misma persona si coinciden
    # el nombre completo, la edad y la estaca; solo el nombre no basta: dos «María López» pueden existir.
    def duplicate_of(values)
      document = Participant.normalize_value_for(:identity_document, values[:identity_document])
      return Participant.find_by(identity_document: document) if document
      return if values[:first_name].blank?

      Participant.find_by(first_name: values[:first_name], last_name: values[:last_name],
                          age: whole_number(values[:age]), stake: enum_key(Participant.stakes, values[:stake]))
    end

    def staff_role?(values)
      rol = enum_key(Participant.rols, values[:rol])
      rol.present? && rol != "joven"
    end

    # El staff se asigna como en la app: consejeros a su compañía y auxiliares a su compañía auxiliar, un
    # hombre y una mujer por rol en cada una. Lo que no se puede asignar se avisa para resolverlo a mano;
    # nunca se fuerza (y un choque en el índice único abortaría toda la carga).
    # Devuelve [notas, ficha con la que choca].
    def staffing_notes(participant, values)
      case participant.rol
      when "consejero"
        company = Company.find_by(number: values[:company_number].to_s.gsub(/\D/, "").presence&.to_i) if values[:company_number].present?
        return [ [ "consejero sin compañía: asígnalo a mano" ], nil ] if values[:company_number].blank?
        return [ [ "la compañía #{values[:company_number]} no existe: asígnalo a mano" ], nil ] unless company

        assign(participant, company, "#{company.name} ya tiene consejer#{participant.gender == 'M' ? 'a' : 'o'}")
      when "auxiliar"
        auxiliar_company = auxiliar_company_for(values)
        return [ [ "auxiliar sin compañía auxiliar: asígnalo a mano" ], nil ] if auxiliar_company == :missing
        return [ [ "la compañía auxiliar «#{values[:auxiliar_company] || values[:company_number]}» no existe: asígnalo a mano" ], nil ] if auxiliar_company.nil?

        assign(participant, auxiliar_company, "#{auxiliar_company.name} ya tiene auxiliar #{participant.gender == 'M' ? 'mujer' : 'hombre'}")
      else
        # El joven usa la compañía como la suya (company_id); al resto del staff no le aplica.
        staff_role?(values) && values[:company_number].present? ? [ [ "la compañía no aplica a su rol: se ignoró" ], nil ] : [ [], nil ]
      end
    end

    def assign(participant, target, full_message)
      gender = Participant.genders[participant.gender]
      occupant = Membership.find_by(associable: target, role: participant.rol, gender: gender)&.participant
      return [ [ "#{full_message} (#{occupant.full_name}): no se asignó, resuélvelo a mano" ], occupant ] if occupant

      membership = Membership.new(associable: target, participant: participant)
      return [ [], nil ] if membership.save

      [ [ "no se pudo asignar a #{target.name} (#{membership.errors.full_messages.to_sentence}): resuélvelo a mano" ], nil ]
    end

    # Por nombre, con o sin «Auxiliar» y sin importar acentos («Épsilon», «auxiliar epsilon»). Si no viene,
    # la de su compañía, cuando trae número de compañía.
    def auxiliar_company_for(values)
      if values[:auxiliar_company].present?
        wanted = normalize(values[:auxiliar_company]).delete_prefix("auxiliar ").strip
        AuxiliarCompany.all.find { |auxiliar| normalize(auxiliar.name).delete_prefix("auxiliar ").strip == wanted }
      elsif values[:company_number].present?
        Company.find_by(number: values[:company_number].to_s.gsub(/\D/, "").to_i)&.auxiliar_company
      else
        :missing
      end
    end

    def warn_about(participant, values, number, staffing = [ [], nil ])
      others = Participant.where.not(id: participant.id)
      notes, staffing_match = staffing
      notes = notes.dup
      matches = [ staffing_match ].compact
      if (same = others.find_by(first_name: participant.first_name, last_name: participant.last_name))
        notes << "mismo nombre que otra persona"
        matches << same
      end
      if participant.email_address.present? &&
         (same = others.find_by("lower(contact_info ->> 'email_address') = ?", participant.email_address.downcase))
        notes << "mismo correo que otra persona"
        matches << same
      end
      # Los últimos 8 dígitos: «+505 8888 1111» y «8888-1111» son el mismo número.
      if (phone = participant.phone_number.to_s.gsub(/\D/, "").last(8)).length == 8 &&
         (same = others.find_by("right(regexp_replace(contact_info ->> 'phone_number', '\\D', '', 'g'), 8) = ?", phone))
        notes << "mismo teléfono que otra persona"
        matches << same
      end
      if values[:company_number].present? && !staff_role?(values) && participant.company_id.nil?
        notes << "la compañía #{values[:company_number]} no existe: quedó sin compañía"
      end
      @warnings << Row.new(number: number, name: participant.full_name, reason: notes.join(" · "), match: matches.first, record: participant) if notes.any?
    end
end
