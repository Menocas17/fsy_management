class Participant < ApplicationRecord
  # Borrar la ficha borra su cuenta: una cuenta sin ficha no tiene a quién representar.
  has_one :user, dependent: :destroy
  belongs_to :company, optional: true
  belongs_to :logistics_area, optional: true

  has_one :checkin, dependent: :destroy
  has_many :training_attendances, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :companies, through: :memberships, source: :associable, source_type: "Company"
  has_many :auxiliar_companies, through: :memberships, source: :associable, source_type: "AuxiliarCompany"

  enum :rol, { director: 0, coordinador: 1, auxiliar: 2, consejero: 3, registrador: 4, logistica: 5, joven: 6, director_logistica: 7 }

  ROLE_LABELS = {
    "director" => "Director", "coordinador" => "Coordinador", "auxiliar" => "Auxiliar", "consejero" => "Consejero",
    "registrador" => "Registrador", "logistica" => "Logística", "director_logistica" => "Director de logística", "joven" => "Joven"
  }.freeze
  enum :stake, { bello_horizonte: 0, las_americas: 1, villa_flor: 2, puerto_cabezas: 3 }
  enum :ward, { bello_horizonte_b: 0, ciudad_jardin: 1, ducuali: 2, la_maximo_jerez: 3, la_rotonda: 4, primavera: 5, waspan: 6 }
  enum :shirt_number, { xs: 0, s: 1, m: 2, l: 3, xl: 4 }
  enum :gender, { M: 0, H: 1 }

  GENDER_LABELS = { "H" => "Hombre", "M" => "Mujer" }.freeze

  # With this you can access to the structure of the jsonb columns and treat them as they were actual columns
  store_accessor :contact_info, :phone_number, :email_address, :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation
  store_accessor :person_in_charge, :m_person_in_charge, :h_person_in_charge
  store_accessor :medical_info, :allergies, :medicines, :diet, :additional_medical_notes

  validates :first_name, :last_name, :age, :stake, :shirt_number, :gender, presence: true
  validates :age, presence: true, numericality: { greater_than: 0, less_than: 80, allow_nil: true }

  after_save :sync_membership_gender

  # Al consejero lo ubican dos cosas: la «Compañía» de su ficha y su lugar en el personal de la compañía
  # (Membership), que es lo que leen la compañía, el organigrama y la asistencia nocturna. Se mantienen
  # iguales desde los dos lados: aquí al editar la ficha, y en Membership al asignarlo desde la compañía.
  validate :counselor_slot_free, if: -> { consejero? && company_id.present? &&
                                          (will_save_change_to_company_id? || will_save_change_to_rol? || will_save_change_to_gender?) }
  after_save :sync_counselor_membership, if: -> { saved_change_to_company_id? || saved_change_to_rol? }

  # Cédula: se guarda en mayúsculas y sin guiones ni espacios (001-010190-0001A → 0010101900001A), así
  # la misma cédula escrita de dos formas es la misma. formatted_identity_document le devuelve los guiones.
  normalizes :identity_document, with: ->(value) { value.to_s.upcase.gsub(/[^0-9A-Z]/, "").presence }
  before_create :assign_code

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
  scope :staff,   -> { where(rol: [ "logistica", "director_logistica", "coordinador", "director", "consejero", "auxiliar", "registrador" ]) }
  scope :search_by_name, ->(query) { where("first_name ILIKE :q OR last_name ILIKE :q", q: "%#{query}%") if query.present? }
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

  CARE_FILTERS = { "allergies" => "Con alergias", "diet" => "Con dieta especial", "medicines" => "Toman medicinas" }.freeze

  # El filtro que llega desde el panel de cocina y salud.
  scope :by_care, ->(field) { with_medical_note(field) if CARE_FILTERS.key?(field.to_s) }

  # Quiénes necesitan atención especial en cocina o enfermería.
  scope :with_medical_note, ->(field) {
    where("btrim(coalesce(medical_info ->> :field, '')) <> ''", field: field.to_s)
      .where("lower(btrim(medical_info ->> :field)) <> ALL (ARRAY[:none]::text[])", field: field.to_s, none: MEDICAL_NONE)
  }


  # this code will manage the avatar of the participants and will transform the image in a thumbnail image for the profile
  has_one_attached :avatar do |attachable|
   attachable.variant :thumb, resize_to_limit: [ 300, 300 ],
   preprocessed: true
   attachable.variant :preview, resize_to_limit: [ 1200, 1200 ],
   preprocessed: true
  end


  def full_name
    "#{first_name} #{last_name}"
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

  def self.data_by_age
    group(:age).count
  end

  def self.jovenes_count
    jovenes.count
  end

  def self.staff_count
    staff.count
  end

  def self.stake_count
    group(:stake).count.transform_keys(&:titleize)
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
