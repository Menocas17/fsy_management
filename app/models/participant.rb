class Participant < ApplicationRecord
  has_one :user, dependent: :nullify


  enum :rol, { director: 0, coordinador: 1, auxiliar: 2, consejero: 3, registrador: 4, logistica: 5, joven: 6 }
  enum :stake, { bello_horizonte: 0, las_americas: 1, villa_flor: 2, puerto_cabezas: 3 }
  enum :ward, { bello_horizonte_b: 0, ciudad_jardin: 1, ducuali: 2, la_maximo_jerez: 3, la_rotonda: 4, primavera: 5, waspan: 6 }
  enum :shirt_number, { xs: 0, s: 1, m: 2, l: 3, xl: 4 }
  enum :genre, { M: 0, H: 1 }

  # With this you can access to the structure of the jsonb columns and treat them as they were actual columns
  store_accessor :contact_info, :phone_number, :email_address, :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation
  store_accessor :person_in_charge, :m_person_in_charge, :h_person_in_charge
  store_accessor :medical_info, :allergies, :medicines, :diet, :additional_medical_notes

  validates :first_name, :last_name, :age, :stake, :shirt_number, :genre, presence: true
  validates :age, presence: true, numericality: { greater_than: 0, less_than: 80 }

  scope :jovenes, -> { where(rol: "joven") }
  scope :staff,   -> { where(rol: [ "logistica", "coordinador", "director", "consejero", "auxiliar", "registrador" ]) }
  scope :search_by_name, ->(query) { where("first_name ILIKE :q OR last_name ILIKE :q", q: "%#{query}%") if query.present? }
  scope :by_stake, ->(stake) { where(stake: stake) if stake.present? }
  scope :by_ward, ->(ward) { where(ward: ward) if ward.present? }
  scope :by_genre, ->(genre) { where(genre: genre) if genre.present? }
  scope :by_company, ->(query) { where(company: query) if query.present? }
  scope :by_role, ->(role) { where(rol: role) if role.present? }


  # this code will manage the avatar of the participants and will transform the image in a thumbnail image for the profile
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 300, 300 ]
    attachable.variant :preview, resize_to_limit: [ 1200, 1200 ],
    preprocessed: true
  end


  def full_name
    "#{first_name} #{last_name}"
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
    group(:rol).count
  end

  def self.male_count
    where(genre: "H").count
  end

  def self.female_count
    where(genre: "M").count
  end

  def self.shirt_count
    group(:shirt_number).count
  end


  def self.allowed_attributes_for(user)
    allowed_attributes = []

    if user&.counselers_staff? || user&.admin_or_staff_manager?
      allowed_attributes += [ :avatar, :room, :shirt_number, :phone_number, :email_address, :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation, :allergies, :medicines, :diet, :additional_medical_notes, :additional_intructions ]
    end

    if user&.admin_or_staff_manager?
      allowed_attributes += [ :company, :m_person_in_charge, :h_person_in_charge, :identity_document, :genre, :stake, :ward, :rol ]
    end

    if user&.participant_id.nil?
      allowed_attributes = [
        :avatar, :room, :shirt_number, :phone_number, :email_address, :first_name, :last_name, :age,
        :emergency_contact_number, :emergency_contact_name, :emergency_contact_relation,
        :allergies, :medicines, :diet, :additional_medical_notes, :additional_intructions,
        :company, :m_person_in_charge, :h_person_in_charge,
        :identity_document, :genre, :stake, :ward, :rol
      ]
    end

    allowed_attributes.uniq
  end

  private
end
