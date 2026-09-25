require "roo"

# Carga masiva de participantes desde un Excel. Las cabeceras se reconocen sin importar mayúsculas,
# acentos ni espacios, así que el archivo real del registro debería entrar sin retoques; si trae otras
# columnas, se agregan a HEADERS y listo.
class ParticipantImporter
  class UnreadableFile < StandardError; end

  Row = Struct.new(:number, :name, :reason, keyword_init: true)

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

  GENDERS = { "h" => "H", "hombre" => "H", "masculino" => "H", "m" => "M", "mujer" => "M", "femenino" => "M" }.freeze

  attr_reader :imported, :skipped, :fatal

  def initialize(file)
    @file = file
    @imported = []
    @skipped = []
  end

  def call
    sheet = open_sheet
    headers = map_headers(sheet.row(1))
    raise UnreadableFile, "El archivo no tiene ninguna columna reconocible (revisá la primera fila)." if headers.values.none?

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
      raise UnreadableFile, "No se pudo leer el archivo (#{error.class}). Subí un .xlsx o un .csv."
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

      if duplicate?(values)
        @skipped << Row.new(number: number, name: name, reason: "ya estaba registrado")
        return
      end

      participant = Participant.new(attributes_for(values))
      if participant.save
        @imported << participant
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
        age: values[:age]&.to_i, gender: GENDERS[normalize(values[:gender])],
        stake: enum_key(Participant.stakes, values[:stake]),
        ward: enum_key(Participant.wards, values[:ward]),
        shirt_number: enum_key(Participant.shirt_numbers, values[:shirt_number]),
        rol: enum_key(Participant.rols, values[:rol]) || "joven",
        identity_document: values[:identity_document].presence&.to_s&.gsub(/\D/, "").presence&.to_i,
        room: values[:room]&.to_s,
        company_id: company_id_for(values[:company_number]),
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

    def company_id_for(number)
      return nil if number.blank?

      @companies ||= Company.pluck(:number, :id).to_h
      @companies[number.to_s.gsub(/\D/, "").to_i]
    end

    # La cédula manda cuando viene; si no, el nombre completo evita duplicar a la misma persona.
    def duplicate?(values)
      document = values[:identity_document].presence&.to_s&.gsub(/\D/, "").presence
      return Participant.exists?(identity_document: document.to_i) if document

      values[:first_name].present? &&
        Participant.exists?(first_name: values[:first_name], last_name: values[:last_name])
    end
end
