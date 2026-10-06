# Lo que dice una fila de la carga masiva (del archivo, o ya corregida a mano): qué ficha saldría, qué
# problemas tiene y a qué compañía iría su staff. La usan la carga (para decidir si entra directo o queda
# en espera) y la pantalla de conflictos (para volver a revisarla al editarla y al aprobarla).
#
# Cada problema es { "text", "blocking", "match_id" }:
#   blocking: true  → impide aprobar hasta corregirlo (dato inválido, duplicado, lugar ocupado…).
#   blocking: false → aviso: se puede aprobar igual, sabiéndolo (mismo teléfono, sin compañía…).
#   match_id        → la ficha con la que choca, para abrirla y comparar.
class ImportRowEvaluator
  # Los roles en femenino, como vienen en muchas planillas.
  ROLE_ALIASES = {
    "directora" => "director", "coordinadora" => "coordinador", "consejera" => "consejero",
    "directora de logistica" => "director_logistica", "jovenes" => "joven",
    # El rol registrador ya no existe: quien registra es de logística, con la bandera Registro en su área.
    "registrador" => "logistica", "registradora" => "logistica"
  }.freeze

  # «M» es mujer, como en la app (H/M); «F» (femenino) también, porque así vienen muchos formularios.
  GENDERS = { "h" => "H", "hombre" => "H", "masculino" => "H", "varon" => "H",
              "m" => "M", "mujer" => "M", "femenino" => "M", "f" => "M" }.freeze

  attr_reader :values, :participant, :issues

  def initialize(values)
    @values = values.to_h.transform_keys(&:to_sym).transform_values { |value| value.is_a?(String) ? value.strip.presence : value }
    @issues = []
  end

  def self.normalize(value)
    value.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase.squish
  end

  def evaluate
    @issues = []
    @participant = Participant.new(attributes)
    check_duplicate
    check_dates
    check_ward
    check_validity
    check_staffing
    check_lookalikes
    check_role_and_company
    check_logistics_area
    self
  end

  # La ficha que saldría de la fila, sin revisarla contra la base: la siembra de datos de prueba (EventSeed).
  def build
    @participant = Participant.new(attributes)
  end

  def clean?
    issues.empty?
  end

  def blocking?
    issues.any? { |issue| issue["blocking"] }
  end

  def name
    [ values[:first_name], values[:last_name] ].compact_blank.join(" ").presence || "sin nombre"
  end

  # Crea la ficha y la asigna a su compañía o compañía auxiliar. Solo sin problemas que bloqueen.
  def apply!
    evaluate
    return false if blocking?

    Participant.transaction do
      participant.save!
      Membership.create!(associable: staffing_target, participant: participant) if staffing_target
    end
    participant
  end

  private
    def attributes
      {
        first_name: values[:first_name], last_name: values[:last_name], preferred_name: values[:preferred_name],
        age: whole_number(values[:age]), birth_date: birth_date, date_of_inscription: date(values[:date_of_inscription]),
        gender: GENDERS[normalize(values[:gender])],
        stake: stake_key, ward: (ward_key if stake_key),
        # El staff puede venir de una estaca que no participa: queda escrita tal cual.
        other_stake: (values[:stake]&.to_s if stake_key.nil?), other_ward: (values[:ward]&.to_s if stake_key.nil?),
        bishop_name: values[:bishop_name], bishop_email: values[:bishop_email],
        shirt_number: enum_key(Participant.shirt_numbers, values[:shirt_number]),
        rol: role_key || "joven",
        identity_document: values[:identity_document]&.to_s,
        room: values[:room]&.to_s,
        # La compañía de un joven es la suya; el staff se asigna a una compañía por su membresía.
        company_id: (company&.id unless staff?),
        logistics_area_id: (logistics_area&.id if logistics_committee?),
        phone_number: values[:phone_number]&.to_s, email_address: values[:email_address],
        emergency_contact_name: values[:emergency_contact_name],
        emergency_contact_number: values[:emergency_contact_number]&.to_s,
        emergency_contact_relation: values[:emergency_contact_relation],
        emergency_contact_email: values[:emergency_contact_email],
        emergency_contact_2_name: values[:emergency_contact_2_name],
        emergency_contact_2_number: values[:emergency_contact_2_number]&.to_s,
        emergency_contact_2_email: values[:emergency_contact_2_email],
        medical_information: medical_information, emotional_information: values[:emotional_information],
        diet: values[:diet],
        additional_instructions: values[:additional_instructions]
      }.compact
    end

    def add(text, blocking:, match: nil)
      @issues << { "text" => text, "blocking" => blocking, "match_id" => match&.id }
    end

    # La cédula manda cuando viene (escrita como sea). Sin ella, es la misma persona si coinciden el nombre
    # completo y la fecha de nacimiento, o (sin fecha) la edad y la estaca; solo el nombre no basta: dos
    # «María López» pueden existir.
    def check_duplicate
      document = participant.identity_document
      existing = if document
        Participant.find_by(identity_document: document)
      elsif values[:first_name].present? && participant.birth_date
        Participant.find_by(first_name: participant.first_name, last_name: participant.last_name, birth_date: participant.birth_date)
      elsif values[:first_name].present?
        Participant.find_by(first_name: participant.first_name, last_name: participant.last_name,
                            age: participant.age, stake: participant.stake)
      end
      add("Duplicado: esta persona ya existe", blocking: true, match: existing) if existing
    end

    def check_dates
      add("La fecha de nacimiento «#{values[:birth_date]}» no se entiende (usa día/mes/año)", blocking: true) if values[:birth_date].present? && birth_date.nil?
      add("La fecha de inscripción «#{values[:date_of_inscription]}» no se entiende: se ignora", blocking: false) if values[:date_of_inscription].present? && date(values[:date_of_inscription]).nil?
    end

    # Un barrio que no está en la lista: el joven tiene que ser de uno de los que participan; al staff se le deja sin barrio.
    def check_ward
      return if values[:ward].blank? || stake_key.nil? || ward_key

      if staff?
        add("El barrio «#{values[:ward]}» no está en la lista: quedaría sin barrio", blocking: false)
      else
        add("El barrio «#{values[:ward]}» no es de la #{Participant::STAKE_LABELS[stake_key]}", blocking: true)
      end
    end

    def check_validity
      return if participant.valid?

      # Un tercer director, coordinador o director de logística: se compara con quien ya ocupa el lugar.
      occupant = participant.leadership_occupant
      participant.errors.full_messages.each do |message|
        add(message, blocking: true, match: (occupant if message.start_with?("Ya hay")))
      end
    end

    # Consejeros a su compañía y auxiliares a su compañía auxiliar: un hombre y una mujer por rol en cada una.
    def check_staffing
      case participant.rol
      when "consejero"
        if values[:company_number].blank?
          add("Consejero sin compañía: se puede aprobar y asignarlo después", blocking: false)
        elsif company.nil?
          add("La compañía #{values[:company_number]} no existe", blocking: true)
        else
          check_slot(company, "#{company.name} ya tiene consejer#{participant.gender == 'M' ? 'a' : 'o'}")
        end
      when "auxiliar"
        if auxiliar_company == :missing
          add("Auxiliar sin compañía auxiliar: se puede aprobar y asignarlo después", blocking: false)
        elsif auxiliar_company.nil?
          add("La compañía auxiliar «#{values[:auxiliar_company] || values[:company_number]}» no existe", blocking: true)
        else
          check_slot(auxiliar_company, "#{auxiliar_company.name} ya tiene auxiliar #{participant.gender == 'M' ? 'mujer' : 'hombre'}")
        end
      end
    end

    def check_slot(target, message)
      occupant = Membership.find_by(associable: target, role: participant.rol, gender: Participant.genders[participant.gender])&.participant
      add("#{message}: #{occupant.full_name}", blocking: true, match: occupant) if occupant
    end

    def staffing_target
      return company if participant.consejero?
      return auxiliar_company if participant.auxiliar? && auxiliar_company.is_a?(AuxiliarCompany)

      nil
    end

    def check_lookalikes
      return if issues.any? { |issue| issue["text"].start_with?("Duplicado") }

      others = Participant.all
      if participant.first_name.present? && (same = others.find_by(first_name: participant.first_name, last_name: participant.last_name))
        add("Mismo nombre que otra persona", blocking: false, match: same)
      end
      if participant.email_address.present? &&
         (same = others.find_by("lower(contact_info ->> 'email_address') = ?", participant.email_address.downcase))
        add("Mismo correo que otra persona", blocking: false, match: same)
      end
      # Los últimos 8 dígitos: «+505 8888 1111» y «8888-1111» son el mismo número.
      phone = participant.phone_number.to_s.gsub(/\D/, "").last(8)
      if phone.length == 8 &&
         (same = others.find_by("right(regexp_replace(contact_info ->> 'phone_number', '\\D', '', 'g'), 8) = ?", phone))
        add("Mismo teléfono que otra persona", blocking: false, match: same)
      end
    end

    def check_role_and_company
      add("El rol «#{values[:rol]}» no existe: entraría como joven", blocking: false) if values[:rol].present? && role_key.nil?
      return if values[:company_number].blank?

      if staff? && !participant.consejero? && !participant.auxiliar?
        add("La compañía no aplica a su rol: se ignora", blocking: false)
      elsif !staff? && company.nil?
        add("La compañía #{values[:company_number]} no existe: quedaría sin compañía", blocking: false)
      end
    end

    # El área es del comité de logística; a otro rol no se le pone. Un área que no existe no se crea sola:
    # sus banderas dan permisos, así que se crea a propósito en Áreas.
    def check_logistics_area
      return if values[:logistics_area].blank?

      if !logistics_committee?
        add("El área no aplica a su rol: se ignora", blocking: false)
      elsif logistics_area.nil?
        add("El área «#{values[:logistics_area]}» no existe: quedaría sin área (créala en Áreas)", blocking: false)
      end
    end

    def logistics_committee?
      %w[logistica director_logistica].include?(role_key)
    end

    # Por nombre, sin importar mayúsculas ni acentos.
    def logistics_area
      return @logistics_area if defined?(@logistics_area)

      wanted = normalize(values[:logistics_area])
      @logistics_area = wanted.presence && LogisticsArea.all.find { |area| normalize(area.name) == wanted }
    end

    def staff?
      (role_key || "joven") != "joven"
    end

    def role_key
      value = values[:rol]
      return nil if value.blank?

      enum_key(Participant.rols, value) || ROLE_ALIASES[normalize(value)] ||
        Participant.rols.keys.find { |key| normalize(Participant.role_label(key)) == normalize(value) }
    end

    def company
      return @company if defined?(@company)

      number = values[:company_number].to_s.gsub(/\D/, "").presence
      @company = number && Company.find_by(number: number.to_i)
    end

    # Por nombre, con o sin «Auxiliar» y sin importar acentos. Si no viene, la de su compañía.
    def auxiliar_company
      return @auxiliar_company if defined?(@auxiliar_company)

      @auxiliar_company =
        if values[:auxiliar_company].present?
          wanted = normalize(values[:auxiliar_company]).delete_prefix("auxiliar ").strip
          AuxiliarCompany.all.find { |auxiliar| normalize(auxiliar.name).delete_prefix("auxiliar ").strip == wanted }
        elsif values[:company_number].present?
          company&.auxiliar_company
        else
          :missing
        end
    end

    # «Estaca Managua Nicaragua Bello Horizonte» → bello_horizonte: la clave exacta, o la más larga que
    # aparezca entera dentro del nombre. El barrio se busca solo entre los de su estaca, así «Rama Loma Verde»
    # es la de Puerto Cabezas o el barrio de Las Américas según la estaca de la fila.
    def stake_key
      @stake_key = contained_key(Participant.stakes, values[:stake]) unless defined?(@stake_key)
      @stake_key
    end

    def ward_key
      unless defined?(@ward_key)
        wards = Participant::WARDS_BY_STAKE.fetch(stake_key.to_s, []).index_with do |ward|
          Participant.ward_label(ward).delete_prefix("Barrio ").delete_prefix("Rama ")
        end
        @ward_key = contained_key(wards, values[:ward])
      end
      @ward_key
    end

    # mapping: { clave => nombre opcional }. Cuenta la clave («la_maximo_jerez») o el nombre («La Máximo Jerez»).
    def contained_key(mapping, value)
      return nil if value.blank?

      words = ->(text) { " #{normalize(text).gsub(/[^a-z0-9]+/, " ").strip} " }
      text = words.(value)
      matches = mapping.keys.flat_map { |key| [ key.tr("_", " "), mapping[key].is_a?(String) ? mapping[key] : nil ].compact.map { [ key, words.(_1) ] } }
      matches.select { |_, name| text.include?(name) }.max_by { |_, name| name.length }&.first
    end

    def birth_date
      @birth_date = date(values[:birth_date]) unless defined?(@birth_date)
      @birth_date
    end

    # La información médica tal cual; las planillas viejas traen alergias y medicinas aparte y se juntan.
    def medical_information
      parts = [ values[:medical_information] ]
      parts << "Alergias: #{values[:allergies]}" if medical_value?(values[:allergies])
      parts << "Medicinas: #{values[:medicines]}" if medical_value?(values[:medicines])
      parts.compact_blank.map(&:to_s).join("\n").presence
    end

    def medical_value?(value)
      value.present? && !Participant::MEDICAL_NONE.include?(normalize(value))
    end

    # 2010-03-14 (Excel, ya convertida), 14/03/2010 o 14-03-2010 (día primero, como se escribe aquí).
    def date(value)
      return value.to_date if value.respond_to?(:to_date) && !value.is_a?(String)

      text = value.to_s.strip
      return nil if text.empty?

      if (match = text.match(/\A(\d{4})-(\d{1,2})-(\d{1,2})/))
        Date.new(match[1].to_i, match[2].to_i, match[3].to_i)
      elsif (match = text.match(%r{\A(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})\z}))
        year = match[3].to_i
        year += year < 30 ? 2000 : 1900 if year < 100
        Date.new(year, match[2].to_i, match[1].to_i)
      end
    rescue Date::Error
      nil
    end

    # «15», 15 o 15.0 → 15. Lo que no es número se deja tal cual, para que el error diga «debe ser un número».
    def whole_number(value)
      return value.to_i if value.is_a?(Numeric)

      value.to_s.strip.match?(/\A\d+(\.0+)?\z/) ? value.to_i : value
    end

    # «Bello Horizonte» → bello_horizonte, «M» → m.
    def enum_key(mapping, value)
      return nil if value.blank?

      needle = normalize(value).tr(" ", "_")
      mapping.keys.find { |key| key == needle || normalize(key.tr("_", " ")) == normalize(value) }
    end

    def normalize(value)
      self.class.normalize(value)
    end
end
