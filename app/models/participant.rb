class Participant < ApplicationRecord
  # Borrar la ficha borra su cuenta: una cuenta sin ficha no tiene a quién representar.
  has_one :user, dependent: :destroy
  belongs_to :company, optional: true
  belongs_to :logistics_area, optional: true

  has_one :checkin, dependent: :destroy
  has_many :training_attendances, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :infirmary_visits, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :companies, through: :memberships, source: :associable, source_type: "Company"
  has_many :auxiliar_companies, through: :memberships, source: :associable, source_type: "AuxiliarCompany"

  # Los jóvenes de práctica del tutorial (ver practice_jovenes) no existen para el resto de la app: ni listas,
  # ni cifras, ni reportes, ni búsquedas, ni Conteo. Solo el tutorial los carga, con Participant.unscoped.
  default_scope { where(practice: false) }

  enum :rol, { director: 0, coordinador: 1, auxiliar: 2, consejero: 3, logistica: 5, joven: 6, director_logistica: 7 }

  ROLE_LABELS = {
    "director" => "Director", "coordinador" => "Coordinador", "auxiliar" => "Auxiliar", "consejero" => "Consejero",
    "logistica" => "Logística", "director_logistica" => "Director de logística", "joven" => "Joven"
  }.freeze
  enum :stake, { bello_horizonte: 0, las_americas: 1, villa_flor: 2, puerto_cabezas: 3 }
  # Los nombres del barrio y de su estaca se repiten (Barrio Villa Flor en la Estaca Villa Flor), así que los
  # métodos del barrio llevan prefijo: ward_villa_flor?. Los números ya guardados no se mueven.
  enum :ward, {
    bello_horizonte: 0, ciudad_jardin: 1, ducuali: 2, la_maximo_jerez: 3, la_rotonda: 4, primavera: 5, waspan: 6,
    catorce_de_septiembre: 7, los_laureles: 8, rene_polanco: 9, villa_flor: 10, villa_venezuela: 11,
    bocana: 12, ciudadela: 13, las_americas: 14, las_mercedes: 15, loma_verde: 16, ruben_dario: 17, san_benito: 18, tipitapa: 19,
    bilwi: 20, el_caminante: 21, lamlaya: 22, loma_verde_puerto_cabezas: 23, puerto_cabezas: 24
  }, prefix: true

  STAKE_LABELS = {
    "bello_horizonte" => "Estaca Bello Horizonte", "villa_flor" => "Estaca Villa Flor",
    "las_americas" => "Estaca Las Américas", "puerto_cabezas" => "Distrito Puerto Cabezas"
  }.freeze

  # Barrio o rama, como se llama de verdad (dos «Loma Verde»: un barrio en Las Américas y una rama en Puerto Cabezas).
  WARD_LABELS = {
    "bello_horizonte" => "Barrio Bello Horizonte", "ciudad_jardin" => "Barrio Ciudad Jardín", "ducuali" => "Barrio Ducuali",
    "la_maximo_jerez" => "Barrio La Máximo Jerez", "la_rotonda" => "Barrio La Rotonda", "primavera" => "Rama Primavera",
    "waspan" => "Rama Waspán",
    "catorce_de_septiembre" => "Barrio La Catorce de Septiembre", "los_laureles" => "Barrio Los Laureles",
    "rene_polanco" => "Barrio René Polanco", "villa_flor" => "Barrio Villa Flor", "villa_venezuela" => "Barrio Villa Venezuela",
    "bocana" => "Rama Bocana", "ciudadela" => "Barrio Ciudadela", "las_americas" => "Barrio Las Américas",
    "las_mercedes" => "Barrio Las Mercedes", "loma_verde" => "Barrio Loma Verde", "ruben_dario" => "Barrio Rubén Darío",
    "san_benito" => "Rama San Benito", "tipitapa" => "Rama Tipitapa",
    "bilwi" => "Rama Bilwi", "el_caminante" => "Rama El Caminante", "lamlaya" => "Rama Lamlaya",
    "loma_verde_puerto_cabezas" => "Rama Loma Verde", "puerto_cabezas" => "Rama Puerto Cabezas"
  }.freeze

  # Los barrios y ramas de cada estaca: el formulario solo ofrece los de la estaca elegida.
  WARDS_BY_STAKE = {
    "bello_horizonte" => %w[bello_horizonte ciudad_jardin ducuali la_maximo_jerez la_rotonda primavera waspan],
    "villa_flor" => %w[catorce_de_septiembre los_laureles rene_polanco villa_flor villa_venezuela],
    "las_americas" => %w[bocana ciudadela las_americas las_mercedes loma_verde ruben_dario san_benito tipitapa],
    "puerto_cabezas" => %w[bilwi el_caminante lamlaya loma_verde_puerto_cabezas puerto_cabezas]
  }.freeze

  def self.ward_label(ward)
    WARD_LABELS.fetch(ward.to_s, ward.to_s.titleize)
  end

  # El staff puede venir de una estaca que no participa: se elige «Otra» y se escriben a mano.
  OTHER_STAKE = "otra".freeze
  enum :shirt_number, { xs: 0, s: 1, m: 2, l: 3, xl: 4 }
  enum :gender, { M: 0, H: 1 }

  GENDER_LABELS = { "H" => "Hombre", "M" => "Mujer" }.freeze

  # With this you can access to the structure of the jsonb columns and treat them as they were actual columns
  store_accessor :contact_info, :phone_number, :email_address, :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation,
                 :emergency_contact_email, :emergency_contact_2_number, :emergency_contact_2_name, :emergency_contact_2_relation,
                 :emergency_contact_2_email, :bishop_name, :bishop_email
  store_accessor :person_in_charge, :m_person_in_charge, :h_person_in_charge
  # emotional_information es privada: la leen solo quienes leen las notas de enfermería (Authorization).
  store_accessor :medical_info, :medical_information, :emotional_information, :diet, :additional_medical_notes

  validates :first_name, :last_name, :shirt_number, :gender, presence: true
  validates :age, numericality: { greater_than: 0, less_than: 80, allow_nil: true }
  validate :birth_date_or_age
  validate :stake_and_ward

  # La edad sale de la fecha de nacimiento cuando la hay (la que tendrá al empezar el evento, como cuenta FSY);
  # sin ella (fichas viejas), se queda la que tenía.
  # La columna guarda la edad de hoy al guardar la ficha, pero se lee siempre calculada (age): no envejece en la base.
  before_validation -> { self[:age] = age_on(Date.current) }, if: -> { birth_date.present? }
  # Con una estaca de las que participan no quedan los nombres escritos a mano, y sin estaca no hay barrio.
  before_validation :tidy_stake_and_ward

  after_save :sync_membership_gender

  # Un área de logística es del comité: quien deja de ser de logística sale de su área (y de sus banderas).
  before_save -> { self.logistics_area_id = nil }, if: -> { will_save_change_to_rol? && !logistica? && !director_logistica? }

  # Al consejero lo ubican dos cosas: la «Compañía» de su ficha y su lugar en el personal de la compañía
  # (Membership), que es lo que leen la compañía, el organigrama y la asistencia nocturna. Se mantienen
  # iguales desde los dos lados: aquí al editar la ficha, y en Membership al asignarlo desde la compañía.
  validate :counselor_slot_free, if: -> { consejero? && company_id.present? &&
                                          (will_save_change_to_company_id? || will_save_change_to_rol? || will_save_change_to_gender?) }
  after_save :sync_counselor_membership, if: -> { saved_change_to_company_id? || saved_change_to_rol? }

  # Cédula: se guarda en mayúsculas y sin guiones ni espacios (001-010190-0001A → 0010101900001A), así
  # la misma cédula escrita de dos formas es la misma. formatted_identity_document le devuelve los guiones.
  normalizes :identity_document, with: ->(value) { value.to_s.upcase.gsub(/[^0-9A-Z]/, "").presence }
  # Los de práctica no gastan un número de gafete.
  before_create :assign_code, unless: :practice?

  # La dirección del evento es de parejas: un director y una directora (el matrimonio), un coordinador y
  # una coordinadora, un director y una directora de logística. Nunca un tercero: son roles con acceso
  # total (o a todo su comité), así que un duplicado por error sería un problema de seguridad.
  LEADERSHIP_ROLES = %w[director coordinador director_logistica].freeze
  validate :one_per_gender_in_leadership, if: -> { new_record? || will_save_change_to_rol? || will_save_change_to_gender? }

  # Código corto del gafete: una letra (los prefijos del inventario tienen de 2 a 5, así que no chocan) y
  # un número correlativo. Es lo que se escribe a mano cuando el QR no se lee.
  CODE_PREFIX = "P".freeze
  CODE_FORMAT = /\A#{CODE_PREFIX}-\d{4,}\z/

  # Acepta como se escriba: «P-0421», «p0421», «P 421» o solo «421». nil si no parece un código.
  def self.normalize_code(input)
    match = input.to_s.strip.match(/\A#{CODE_PREFIX}?[\s-]*(\d{1,6})\z/i)
    match && format("#{CODE_PREFIX}-%04d", match[1].to_i)
  end

  # Dos jóvenes y dos jóvenas de práctica: con ellos se practica en el tutorial llevar a alguien a enfermería y
  # pasar el Conteo, aunque todavía no haya jóvenes asignados. Se crean la primera vez que se piden.
  PRACTICE_JOVENES = [ [ "Sofía", "M" ], [ "Valeria", "M" ], [ "Mateo", "H" ], [ "Daniel", "H" ] ].freeze

  def self.practice_jovenes
    PRACTICE_JOVENES.map do |first_name, gender|
      unscoped.find_or_create_by!(practice: true, first_name: first_name) do |participant|
        participant.assign_attributes(last_name: "Práctica", gender: gender, rol: :joven, age: 15, shirt_number: :m,
                                      stake: "bello_horizonte", ward: "bello_horizonte", room: "Práctica",
                                      medical_information: "Alergia al maní (de práctica)",
                                      emergency_contact_name: "Contacto de práctica", emergency_contact_number: "0000 0000")
      end
    end
  end

  # Los de práctica tal como los ve quien hace el tutorial: de su compañía (solo en memoria, nunca guardado) y
  # de solo lectura, así ninguna página puede cambiarlos aunque lo intente.
  def self.practice_jovenes_for(company)
    practice_jovenes.each do |participant|
      participant.company = company
      participant.readonly!
    end
  end

  # Dónde le aparecen los jóvenes de práctica a quien hace el tutorial: la compañía del consejero, o la primera
  # de la rama del auxiliar. nil para los demás (y para quien todavía no tiene compañía).
  def practice_company
    case rol
    when "consejero" then counselor_scope.first
    when "auxiliar"  then auxiliar_scope[:companies].first
    end
  end

  # Quien ya ocupa el lugar de este rol y género en la dirección, si lo hay.
  def leadership_occupant
    return unless LEADERSHIP_ROLES.include?(rol.to_s) && gender.present?

    Participant.where(rol: rol, gender: gender).where.not(id: id).first
  end

  # 0010101900001A → 001-010190-0001A. Otros formatos se muestran tal cual.
  def formatted_identity_document
    doc = identity_document.to_s
    doc.match?(/\A\d{13}[A-Z]\z/) ? "#{doc[0, 3]}-#{doc[3, 6]}-#{doc[9, 5]}" : doc.presence
  end

  # Por id (lo que trae el QR) o por código corto (lo que se escribe).
  def self.find_by_badge(value)
    value = value.to_s.strip.split("/").last.to_s.split("?").first.to_s
    find_by(id: value) || ((code = normalize_code(value)) && find_by(code: code))
  end

  scope :jovenes, -> { where(rol: "joven") }
  scope :staff,   -> { where(rol: [ "logistica", "director_logistica", "coordinador", "director", "consejero", "auxiliar" ]) }
  scope :search_by_name, ->(query) { where("first_name ILIKE :q OR last_name ILIKE :q", q: "%#{query}%") if query.present? }
  # Nombre y apellido juntos, sin importar tildes ni mayúsculas: «ana perez» encuentra a Ana Pérez.
  scope :search_full_name, ->(query) {
    term = "%#{sanitize_sql_like(I18n.transliterate(query.to_s.strip).downcase)}%"
    where("translate(lower(concat_ws(' ', first_name, last_name)), :accented, :plain) LIKE :term",
          accented: AuditLog::ACCENTS[0], plain: AuditLog::ACCENTS[1], term: term)
  }
  scope :by_stake, ->(stake) { where(stake: stake) if stake.present? }
  scope :by_ward, ->(ward) { where(ward: ward) if ward.present? }
  scope :by_gender, ->(gender) { where(gender: gender) if gender.present? }
  # A bare number matches that company number exactly ("1" no longer matches "Compañía 10"); other text matches its names.
  scope :by_company, ->(query) {
    term = query.to_s.strip
    next if term.blank?

    if term.match?(/\A\d+\z/)
      joins(:company).where(companies: { number: term.to_i })
    else
      joins(:company).where("companies.name ILIKE :q OR companies.nickname ILIKE :q", q: "%#{sanitize_sql_like(term)}%")
    end
  }
  scope :by_role, ->(role) { where(rol: role) if role.present? }

  # "Ninguna" o "Sin restricciones" es la forma de decir que no hay nada que atender: no cuenta.
  MEDICAL_NONE = [ "ninguna", "ninguno", "ninguna.", "sin restricciones", "sin restriccion", "sin alergias",
                   "sin dieta", "n/a", "na", "no", "-", "--" ].freeze

  CARE_FILTERS = { "medical_information" => "Con información médica", "diet" => "Con dieta especial" }.freeze
  # La información emocional es privada: este filtro solo lo tiene quien tiene acceso total (Authorization#can_filter_emotional_information?).
  EMOTIONAL_FILTER = { "emotional_information" => "Con información emocional" }.freeze

  def self.care_filters(emotional: false)
    emotional ? CARE_FILTERS.merge(EMOTIONAL_FILTER) : CARE_FILTERS
  end

  # El filtro que llega desde el panel de cocina y salud.
  scope :by_care, ->(field, emotional: false) { with_medical_note(field) if care_filters(emotional: emotional).key?(field.to_s) }

  # Quiénes necesitan atención especial en cocina o enfermería.
  scope :with_medical_note, ->(field) {
    where("btrim(coalesce(medical_info ->> :field, '')) <> ''", field: field.to_s)
      .where("lower(btrim(medical_info ->> :field)) <> ALL (ARRAY[:none]::text[])", field: field.to_s, none: MEDICAL_NONE)
  }


  # this code will manage the avatar of the participants and will transform the image in a thumbnail image for the profile
  # :small, para las listas y la barra superior (fotos de 28–40 px): un cuadrado de 128 px en WebP pesa una
  # fracción de :thumb, que sigue para el perfil (92 px). Las fotos anteriores la reciben con fotos:miniaturas.
  has_one_attached :avatar do |attachable|
   attachable.variant :small, resize_to_fill: [ 128, 128 ], format: :webp, saver: { quality: 75, strip: true },
   preprocessed: true
   attachable.variant :thumb, resize_to_limit: [ 300, 300 ],
   preprocessed: true
   attachable.variant :preview, resize_to_limit: [ 1200, 1200 ],
   preprocessed: true
  end


  # Lo mismo que with_attached_avatar, para precargar la foto desde otra asociación (counselors: AVATAR_PRELOAD).
  # Trae las variantes ya procesadas: su llave es la URL pública de la miniatura (ApplicationHelper#storage_url).
  AVATAR_PRELOAD = { avatar_attachment: { blob: { variant_records: { image_attachment: :blob } } } }.freeze

  def full_name
    "#{first_name} #{last_name}"
  end

  # Como le gusta que le digan, si no es su mismo nombre.
  def nickname
    preferred = preferred_name.to_s.strip
    preferred if preferred.present? && ImportRowEvaluator.normalize(preferred) != ImportRowEvaluator.normalize(first_name)
  end

  # «Otra» llega del formulario como una estaca más: deja la estaca vacía y cuenta la escrita a mano.
  def stake=(value)
    @other_stake_chosen = value.to_s == OTHER_STAKE
    super(@other_stake_chosen ? nil : value)
  end

  # Lo que muestra el selector: la estaca, u «Otra» si es una escrita a mano.
  def stake_choice
    stake || (OTHER_STAKE if other_stake.present? || @other_stake_chosen)
  end

  def stake_name
    stake&.titleize || other_stake.presence
  end

  def ward_name
    ward ? self.class.ward_label(ward) : other_ward.presence
  end

  # La de la inscripción oficial (archivo de la Iglesia); sin ella, el día en que se creó la ficha.
  def inscription_date
    date_of_inscription || created_at&.to_date
  end

  # La edad de hoy, con año, mes y día: cambia sola el día del cumpleaños. Sin fecha de nacimiento, la que se
  # escribió a mano (o vino en el archivo).
  def age
    birth_date ? age_on(Date.current) : super
  end

  def age_on(date)
    return if birth_date.nil?

    date.year - birth_date.year - ((date.month > birth_date.month || (date.month == birth_date.month && date.day >= birth_date.day)) ? 0 : 1)
  end

  # Los roles que el superadmin puede probar con «Ver como» (el joven todavía no tiene su propia vista).
  VIEW_AS_ROLES = %w[director coordinador director_logistica logistica auxiliar consejero].freeze

  # Una ficha que muestre bien el rol: primero las que ya tienen cuenta, y entre ellas las que tienen a quién
  # mandar (el consejero su compañía, el auxiliar su rama, logística su área).
  def self.view_as_sample(rol)
    where(rol: rol).includes(:user, :logistics_area, :auxiliar_companies).order(:id).min_by do |participant|
      in_place = case rol.to_s
      when "consejero" then participant.counselor_scope.any?
      when "auxiliar"  then participant.auxiliar_companies.any?
      when "logistica" then participant.logistics_area.present?
      else true
      end
      [ participant.user ? 0 : 1, in_place ? 0 : 1 ]
    end
  end

  def arrived?
    checkin.present?
  end

  # Las capacitaciones son del staff: los jóvenes no van.
  def staff_member?
    !joven?
  end

  def self.role_label(rol)
    ROLE_LABELS.fetch(rol.to_s, rol.to_s.humanize)
  end

  def role_label
    self.class.role_label(rol)
  end

  # Por edad de hoy, como la ficha: con fecha de nacimiento se calcula en la consulta; sin ella, la escrita.
  def self.data_by_age
    group(Arel.sql(sanitize_sql_array([ "COALESCE(date_part('year', age(?::date, birth_date))::int, participants.age)", Date.current ]))).count
  end

  def self.jovenes_count
    jovenes.count
  end

  def self.staff_count
    staff.count
  end

  def self.stake_count
    group(:stake).count.transform_keys { |stake| stake&.titleize || "Otras estacas" }
  end

  def self.role_count
    where.not(rol: nil).group(:rol).count
  end

  def self.male_count
    where(gender: "H").count
  end

  def self.female_count
    where(gender: "M").count
  end

  def self.shirt_count
    group(:shirt_number).count
  end

  scope :coordinators, -> { where(rol: :coordinador) }
  scope :auxiliars,    -> { where(rol: :auxiliar) }
  scope :counselors,   -> { where(rol: :consejero) }

  # Access patterns ------------------------------------------------------------
  # 1) Coordinator: all AuxiliarCompanies it supervises, each with its counselors.
  def auxiliar_companies_with_counselors
    AuxiliarCompany.for_coordinator(self)
  end

  # 2) Auxiliar: the AuxiliarCompany it belongs to, its standard Companies, and
  #    the counselors staffed in those companies.
  #    Los permisos lo consultan varias veces por página: se calcula una vez por objeto (reload lo vuelve a armar).
  def auxiliar_scope
    @auxiliar_scope ||= begin
      company = auxiliar_companies.first
      companies = company ? company.companies.includes(:counselors).to_a : []
      { auxiliar_company: company, counselors: companies.flat_map(&:counselors).uniq, companies: companies }
    end
  end

  def reload(*)
    @auxiliar_scope = nil
    super
  end

  # 3) Counselor: only the standard Company directly assigned.
  def counselor_scope
    companies.includes(:auxiliar_company)
  end


  private
    def birth_date_or_age
      if birth_date.nil? && age.blank?
        errors.add(:birth_date, "no puede estar en blanco")
      elsif birth_date && birth_date > Date.current
        errors.add(:birth_date, "no puede ser en el futuro")
      end
    end

    def tidy_stake_and_ward
      if stake.present?
        self.other_stake = self.other_ward = nil
      else
        self.ward = nil
      end
    end

    # Los jóvenes vienen de las estacas que participan; el staff puede venir de otra, escrita a mano.
    def stake_and_ward
      if stake.blank?
        if joven? && other_stake.present?
          errors.add(:stake, "tiene que ser una de las que participan: «#{other_stake}» solo se acepta para el staff")
        elsif other_stake.blank?
          errors.add(:stake, "no puede estar en blanco")
        end
      # Solo al cambiar la estaca o el barrio: una ficha vieja con una pareja que ya no cuadra no traba otros cambios.
      elsif ward.present? && (will_save_change_to_stake? || will_save_change_to_ward?) && !WARDS_BY_STAKE.fetch(stake, []).include?(ward)
        errors.add(:base, "#{self.class.ward_label(ward)} no es de la #{STAKE_LABELS[stake]}")
      end
    end

    def sync_membership_gender
      if saved_change_to_gender?
        memberships.update_all(gender: gender)
      end
    end

    def counselor_slot_free
      taken = Membership.includes(:participant)
                        .where(associable_type: "Company", associable_id: company_id, role: :consejero, gender: Participant.genders[gender])
                        .where.not(participant_id: id).first
      return unless taken

      errors.add(:base, "#{taken.associable.name} ya tiene #{gender == 'M' ? 'consejera' : 'consejero'}: #{taken.participant.full_name}. " \
                        "Quítalo primero desde la compañía.")
    end

    def sync_counselor_membership
      in_companies = memberships.where(associable_type: "Company", role: :consejero)
      if consejero? && company_id.present?
        in_companies.where.not(associable_id: company_id).destroy_all
        memberships.find_or_create_by!(associable_type: "Company", associable_id: company_id)
      else
        in_companies.destroy_all
      end
    end

    def one_per_gender_in_leadership
      occupant = leadership_occupant
      return unless occupant

      errors.add(:base, "Ya hay #{Participant.role_label(rol).downcase} #{gender == 'M' ? 'mujer' : 'hombre'}: #{occupant.full_name} (solo uno por género)")
    end

    def assign_code
      return if code.present?

      last = Participant.where.not(code: nil).maximum(Arel.sql("substring(code from 3)::int")) || 0
      self.code = format("#{CODE_PREFIX}-%04d", last + 1)
    end
end
