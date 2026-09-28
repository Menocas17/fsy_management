require "roo"

# Carga masiva de participantes desde un Excel. Las cabeceras se reconocen sin importar mayúsculas,
# acentos ni espacios, así que el archivo real del registro debería entrar sin retoques; si trae otras
# columnas, se agregan a HEADERS y listo.
#
# Cada carga queda guardada (ParticipantImport) con una fila por persona: las limpias entran directo y
# las que traen un problema o un aviso quedan en espera, fuera de la base, hasta resolverlas a mano en su
# informe. Qué es un problema lo decide ImportRowEvaluator.
class ParticipantImporter
  class UnreadableFile < StandardError; end

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

  attr_reader :import, :fatal

  def initialize(file, uploaded_by: nil)
    @file = file
    @uploaded_by = uploaded_by
  end

  def call
    sheet = open_sheet
    headers = map_headers(sheet.row(1))
    raise UnreadableFile, "El archivo no tiene ninguna columna reconocible (revisa la primera fila)." if headers.values.none?

    @import = ParticipantImport.create!(filename: filename, uploaded_by: @uploaded_by,
                                        uploaded_by_name: @uploaded_by&.full_name || "Administrador del sistema")
    (2..sheet.last_row).each { |number| process(sheet.row(number), headers, number) }
    self
  rescue UnreadableFile => error
    @fatal = error.message
    self
  end

  private
    def open_sheet
      Roo::Spreadsheet.open(path_for(@file), extension: extension_for(@file)).sheet(0)
    rescue StandardError => error
      raise UnreadableFile, "No se pudo leer el archivo (#{error.class}). Sube un .xlsx o un .csv."
    end

    def path_for(file)
      file.respond_to?(:tempfile) ? file.tempfile.path : file.to_s
    end

    def filename
      @file.respond_to?(:original_filename) ? @file.original_filename : File.basename(@file.to_s)
    end

    def extension_for(file)
      name = file.respond_to?(:original_filename) ? file.original_filename : file.to_s
      File.extname(name).delete(".").downcase.presence&.to_sym || :xlsx
    end

    # Posición de cada columna reconocida: { first_name: 0, age: 1, ... }
    def map_headers(row)
      row.each_with_index.each_with_object({}) do |(cell, index), found|
        key = HEADERS[ImportRowEvaluator.normalize(cell)]
        found[key] ||= index if key
      end
    end

    def process(row, headers, number)
      values = headers.transform_values { |index| clean(row[index]) }
      return if values.values.all?(&:blank?)

      evaluation = ImportRowEvaluator.new(values).evaluate
      participant = evaluation.clean? && evaluation.apply!
      if participant
        @import.rows.create!(row_number: number, values: values, status: :imported, participant: participant)
      else
        @import.rows.create!(row_number: number, values: values, status: :pending, issues: evaluation.issues)
      end
    end

    # Texto sin espacios de más; un número entero de Excel (15.0, 88881111.0) sin su «.0».
    def clean(value)
      case value
      when String then value.strip.presence
      when Float then value == value.floor ? value.to_i : value
      else value
      end
    end
end
