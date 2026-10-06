class AuxiliarCompany < ApplicationRecord
  has_many :companies, dependent: :nullify
  has_many :memberships, as: :associable, dependent: :destroy
  has_many :auxiliars,  -> { where(rol: :auxiliar) },   through: :memberships, source: :participant
  # Counselors are staffed per company, so an auxiliary company sees the counselors and jóvenes of its companies.
  has_many :counselors, through: :companies
  has_many :jovenes, through: :companies, source: :participants

  validates :name, presence: { message: "no puede estar en blanco" }

  # Los dos coordinadores cuidan de todas las compañías auxiliares: no se eligen por rama.
  scope :coordinated_by, ->(participant) { participant&.coordinador? ? all : none }
  scope :for_coordinator, ->(participant) { coordinated_by(participant).includes(memberships: :participant) }
  scope :with_staff, -> { includes(:companies, :auxiliars, :counselors) }

  # Él primero y luego ella, como en el resto de la app.
  def coordinators
    @coordinators ||= Participant.coordinador.order(gender: :desc, first_name: :asc).to_a
  end

  def coordinator_name
    coordinators.map(&:full_name).to_sentence(two_words_connector: " y ", last_word_connector: " y ").presence || "Sin coordinador"
  end

  # "Auxiliar Gamma" → "G", used for its badge.
  def initial
    name.to_s.delete_prefix("Auxiliar ").strip.first.to_s.upcase.presence || "A"
  end

  def first_company_number
    companies.map(&:number).compact.min
  end

  # "1–5" for consecutive numbers, otherwise a plain list.
  def company_numbers_label
    numbers = companies.map(&:number).compact.sort
    return if numbers.empty?

    consecutive = numbers.size > 1 && numbers.each_cons(2).all? { |previous, current| current == previous + 1 }
    consecutive ? "#{numbers.first}–#{numbers.last}" : numbers.join(", ")
  end

  def staff_status
    case auxiliars.size
    when 2.. then :complete
    when 1 then :missing_auxiliar
    else :no_auxiliars
    end
  end

  def auxiliar_count
    auxiliars.count
  end

  def counselor_count
    counselors.count
  end
end
