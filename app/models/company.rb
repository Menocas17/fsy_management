class Company < ApplicationRecord
  DINING_HALL_LABELS = { "salon_nicaragua" => "Salón Nicaragua", "salon_las_americas" => "Salón Las Américas" }.freeze

  belongs_to :auxiliar_company, optional: true

  has_many :memberships, as: :associable, dependent: :destroy
  has_many :counselors,   -> { where(rol: :consejero) },  through: :memberships, source: :participant
  has_many :auxiliars,    -> { where(rol: :auxiliar) },   through: :memberships, source: :participant
  has_many :participants, -> { where(rol: :joven) },      through: :memberships, source: :participant

  enum :dining_hall, { salon_nicaragua: 0, salon_las_americas: 1 }

  # number is the fixed company number ("Compañía 3"); nickname is the name its participants choose.
  validates :number, numericality: { only_integer: true, greater_than: 0 }, uniqueness: true, allow_nil: true

  scope :with_staff, -> { includes(:counselors, :auxiliars, :participants, :auxiliar_company) }
  scope :by_number, -> { order(:number, :name) }

  def dining_hall_label
    DINING_HALL_LABELS[dining_hall]
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

  def staff_complete?
    counselors.size == 2 && auxiliars.size == 2
  end
end
