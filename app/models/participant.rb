class Participant < ApplicationRecord
  has_one :user, dependent: :nullify
  belongs_to :company, optional: true
  belongs_to :logistics_area, optional: true

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
  validates :age, presence: true, numericality: { greater_than: 0, less_than: 80 }

  after_save :sync_membership_gender

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
  def auxiliar_scope
    company = auxiliar_companies.first
    companies = company ? company.companies.to_a : []
    { auxiliar_company: company, counselors: companies.flat_map(&:counselors).uniq, companies: companies }
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
end
