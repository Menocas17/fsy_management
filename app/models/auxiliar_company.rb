class AuxiliarCompany < ApplicationRecord
  belongs_to :coordinator, class_name: "Participant", optional: true

  has_many :companies
  has_many :memberships, as: :associable, dependent: :destroy
  has_many :auxiliars,  -> { where(rol: :auxiliar) },   through: :memberships, source: :participant
  has_many :counselors, -> { where(rol: :consejero) },  through: :memberships, source: :participant

  scope :for_coordinator, ->(participant) { where(coordinator: participant).includes(memberships: :participant) }
  scope :with_staff, -> { includes(:coordinator, :companies, :auxiliars, :counselors) }

  def coordinator_name
    coordinator&.full_name || "Sin coordinador"
  end

  def auxiliar_count
    auxiliars.count
  end

  def counselor_count
    counselors.count
  end
end
