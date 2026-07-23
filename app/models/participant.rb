class Participant < ApplicationRecord
  enum :rol, { director: 0, coordinador: 1, consejero_auxiliar: 2, consejero: 3, logistica: 4, participante: 5 }
  enum :stake, { bello_horizonte: 0, las_americas: 1, villa_flor: 2, puerto_cabezas: 3 }
  enum :shirt_number, { xs: 0, s: 1, m: 2, l: 3, xl: 4 }
  enum :genre, { M: 0, H: 1 }

  # With this you can access to the structure of the jsonb columns and treat them as they were actual columns
  store_accessor :contact_info, :phone_number, :email_address, :emergency_contact
  store_accessor :respond_to, :m_respond_to, :h_respond_to

  validates :first_name, :last_name, :age, :stake, :shirt_number, :genre, presence: true
  validate :age_must_be_in_range


  # this code will manage the avatar of the participants and will transform the image in a thumbnail image for the profile
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 300, 300 ],
    precompiled: true
  end


  def full_name
    "#{first_name} #{last_name}"
  end



  private

  def age_must_be_in_range
    if age.present? && (age <= 0 || age >= 80)
      errors.add(:age, "should be greater than 0 but less than 80")
    end
  end
end
