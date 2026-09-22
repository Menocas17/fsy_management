class Company < ApplicationRecord
  DINING_HALL_LABELS = { "salon_nicaragua" => "Salón Nicaragua", "salon_las_americas" => "Salón Las Américas" }.freeze

  belongs_to :auxiliar_company, optional: true

  has_many :memberships, as: :associable, dependent: :destroy
  has_many :counselors,   -> { where(rol: :consejero) },  through: :memberships, source: :participant
  has_many :auxiliars,    -> { where(rol: :auxiliar) },   through: :memberships, source: :participant
  # Jóvenes join a company through participants.company_id; memberships only hold staff.
  has_many :participants, -> { where(rol: :joven) }, class_name: "Participant"
  has_many :members, class_name: "Participant", dependent: :nullify

  enum :dining_hall, { salon_nicaragua: 0, salon_las_americas: 1 }, validate: { allow_nil: true, message: "no es un comedor válido" }

  before_validation :name_from_number

  # number is the fixed company number ("Compañía 3"); nickname is the name its participants choose.
  validates :name, presence: { message: "no puede estar en blanco" }
  validates :number, numericality: { only_integer: true, greater_than: 0, message: "debe ser un número entero mayor que 0" },
                     uniqueness: { message: "ya está en uso por otra compañía" }, allow_nil: true
  validates :nickname, length: { maximum: 60, message: "no puede tener más de 60 caracteres" }

  scope :with_staff, -> { includes(:counselors, :auxiliars, :participants, :auxiliar_company) }
  scope :by_number, -> { order(:number, :name) }

  # A bare number finds that company; any other text matches the name, the chosen name or a counselor's name.
  def self.search(query)
    term = query.to_s.strip
    return all if term.blank?
    return where(number: term.to_i) if term.match?(/\A\d+\z/)

    like = "%#{sanitize_sql_like(term)}%"
    counselor_company_ids = Membership.joins(:participant)
                                      .where(associable_type: "Company", role: :consejero)
                                      .where("CONCAT_WS(' ', participants.first_name, participants.last_name) ILIKE ?", like)
                                      .select(:associable_id)
    where("companies.name ILIKE :like OR companies.nickname ILIKE :like", like: like).or(where(id: counselor_company_ids))
  end

  def self.jovenes_counts
    Participant.joven.where.not(company_id: nil).group(:company_id).count
  end

  def self.jovenes_by_dining_hall
    Participant.joven.joins(:company).group("companies.dining_hall").count.transform_keys do |value|
      # The grouped column may come back as the raw integer or already cast to the enum key.
      key = value.is_a?(Integer) ? dining_halls.key(value) : value
      DINING_HALL_LABELS[key] || "Sin salón asignado"
    end
  end

  def self.room_counts
    Participant.joven.where.not(company_id: nil).where.not(room: [ nil, "" ]).group(:company_id).distinct.count(:room)
  end

  def dining_hall_label
    DINING_HALL_LABELS[dining_hall]
  end

  def counselor_names
    counselors.sort_by { |counselor| counselor.gender == "H" ? 0 : 1 }
              .map(&:full_name)
              .to_sentence(two_words_connector: " y ", last_word_connector: " y ")
  end

  def room_occupancy
    participants.where.not(room: [ nil, "" ]).group(:room).order(:room).count
  end

  def staff_status
    case counselors.size
    when 2.. then :complete
    when 1 then :missing_counselor
    else :no_counselors
    end
  end

  def staff_complete?
    staff_status == :complete
  end

  def male_counselor
    counselors.find { |c| c.gender == "H" }
  end

  def female_counselor
    counselors.find { |c| c.gender == "M" }
  end

  def male_auxiliar
    auxiliars.find { |a| a.gender == "H" }
  end

  def female_auxiliar
    auxiliars.find { |a| a.gender == "M" }
  end

  private
    # The number is the company's fixed identity, so its display name always follows it.
    def name_from_number
      self.name = "Compañía #{number}" if number.present? && (new_record? || number_changed?)
    end
end
