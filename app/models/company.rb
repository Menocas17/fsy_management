class Company < ApplicationRecord
  belongs_to :auxiliar_company, optional: true

  has_many :memberships, as: :associable, dependent: :destroy
  has_many :counselors,   -> { where(rol: :consejero) },  through: :memberships, source: :participant
  has_many :auxiliars,    -> { where(rol: :auxiliar) },   through: :memberships, source: :participant
  has_many :participants, -> { where(rol: :joven) },      through: :memberships, source: :participant

  scope :with_staff, -> { includes(:counselors, :auxiliars, :participants, :auxiliar_company) }

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
