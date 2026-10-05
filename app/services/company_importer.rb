require "roo"

# Las compañías del evento desde un Excel, antes de cargar consejeros y jóvenes: una fila por compañía con
# su Número (obligatorio), su Compañía auxiliar y su Comedor. El nombre sale solo («Compañía 7»); el que
# eligen lo ponen ellos durante la semana. Un número que ya existe se actualiza en vez de duplicarse, y una
# compañía auxiliar que no existe se crea. Cada fila entra o falla por su cuenta.
class CompanyImporter
  HEADERS = {
    "numero" => :number, "numero de compania" => :number, "compania" => :number, "no" => :number,
    "compania auxiliar" => :auxiliar_company, "auxiliar" => :auxiliar_company, "rama" => :auxiliar_company,
    "comedor" => :dining_hall, "salon" => :dining_hall
  }.freeze

  Result = Struct.new(:created, :updated, :errors, :fatal, keyword_init: true) do
    def summary
      [ (created.positive? ? "#{created} #{created == 1 ? "compañía nueva" : "compañías nuevas"}" : nil),
        (updated.positive? ? "#{updated} #{updated == 1 ? "actualizada" : "actualizadas"}" : nil) ].compact.join(" y ").presence || "Ninguna compañía cambió"
    end
  end

  def initialize(file)
    @file = file
  end

  def call
    result = Result.new(created: 0, updated: 0, errors: [])
    sheet = open_sheet
    header_row, headers = find_headers(sheet)
    unless headers&.key?(:number)
      result.fatal = "No se encontró la columna «Número» (revisa la fila de los títulos)."
      return result
    end

    ((header_row + 1)..sheet.last_row.to_i).each do |line|
      values = headers.transform_values { |index| clean(sheet.row(line)[index]) }
      next if values.values.all?(&:blank?)

      import_row(values, line, result)
    end
    result
  rescue StandardError => error
    raise if error.is_a?(ActiveRecord::ActiveRecordError)

    Result.new(created: 0, updated: 0, errors: [], fatal: "No se pudo leer el archivo (#{error.class}). Sube un .xlsx o un .csv.")
  end

  private
    def import_row(values, line, result)
      number = values[:number].to_s[/\d+/]
      return result.errors << [ line, "«#{values[:number]}» no es un número de compañía" ] unless number

      company = Company.find_or_initialize_by(number: number.to_i)
      company.auxiliar_company = auxiliar_company_for(values[:auxiliar_company]) if values[:auxiliar_company].present?
      if values[:dining_hall].present?
        hall = dining_hall_for(values[:dining_hall])
        return result.errors << [ line, "El comedor «#{values[:dining_hall]}» no existe" ] unless hall

        company.dining_hall = hall
      end

      created = company.new_record?
      if company.save
        created ? result.created += 1 : (result.updated += 1 if company.saved_changes?)
      else
        result.errors << [ line, "Compañía #{number}: #{company.errors.full_messages.to_sentence}" ]
      end
    end

    # «Alfa», «Auxiliar Alfa» o «auxiliar alfa» son la misma. La que no existe se crea como «Auxiliar Alfa».
    def auxiliar_company_for(name)
      wanted = ImportRowEvaluator.normalize(name).delete_prefix("auxiliar ").strip
      @auxiliar_companies ||= AuxiliarCompany.all.to_a
      @auxiliar_companies.find { |auxiliar| ImportRowEvaluator.normalize(auxiliar.name).delete_prefix("auxiliar ").strip == wanted } ||
        AuxiliarCompany.create!(name: name.to_s.strip.match?(/\Aauxiliar\b/i) ? name.to_s.strip : "Auxiliar #{name.to_s.strip}").tap { @auxiliar_companies << _1 }
    end

    # «Salón Nicaragua», «Nicaragua» o la clave.
    def dining_hall_for(value)
      wanted = ImportRowEvaluator.normalize(value).delete_prefix("salon ").strip
      Company::DINING_HALL_LABELS.find do |key, label|
        [ key.tr("_", " "), label ].any? { ImportRowEvaluator.normalize(_1).delete_prefix("salon ").strip == wanted }
      end&.first
    end

    def find_headers(sheet)
      first = sheet.first_row or return
      (first..[ sheet.last_row.to_i, first + ParticipantImporter::HEADER_SEARCH_ROWS - 1 ].min).each do |line|
        headers = sheet.row(line).each_with_index.each_with_object({}) do |(cell, index), found|
          key = HEADERS[ImportRowEvaluator.normalize(cell).delete_suffix(".")]
          found[key] ||= index if key
        end
        return [ line, headers ] if headers.any?
      end
      nil
    end

    def open_sheet
      path = @file.respond_to?(:tempfile) ? @file.tempfile.path : @file.to_s
      name = @file.respond_to?(:original_filename) ? @file.original_filename : @file.to_s
      Roo::Spreadsheet.open(path, extension: File.extname(name).delete(".").downcase.presence&.to_sym || :xlsx).sheet(0)
    end

    def clean(value)
      case value
      when String then value.strip.presence
      when Float then value == value.floor ? value.to_i : value
      else value
      end
    end
end
