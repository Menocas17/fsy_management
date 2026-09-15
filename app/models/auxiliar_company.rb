class AuxiliarCompany < ApplicationRecord
  # Two coordinators oversee the auxiliary companies; they aren't a couple, so each has their own slot.
  belongs_to :coordinator, class_name: "Participant", optional: true
  belongs_to :second_coordinator, class_name: "Participant", optional: true

  has_many :companies
  has_many :memberships, as: :associable, dependent: :destroy
  has_many :auxiliars,  -> { where(rol: :auxiliar) },   through: :memberships, source: :participant
  has_many :counselors, -> { where(rol: :consejero) },  through: :memberships, source: :participant

  scope :coordinated_by, ->(participant) { where(coordinator: participant).or(where(second_coordinator: participant)) }
  scope :for_coordinator, ->(participant) { coordinated_by(participant).includes(memberships: :participant) }
  scope :with_staff, -> { includes(:coordinator, :second_coordinator, :companies, :auxiliars, :counselors) }

  def coordinators
    [ coordinator, second_coordinator ].compact
  end

  def coordinator_name
    coordinators.map(&:full_name).to_sentence(two_words_connector: " y ", last_word_connector: " y ").presence || "Sin coordinador"
  end

  def auxiliar_count
    auxiliars.count
  end

  def counselor_count
    counselors.count
  end
end
