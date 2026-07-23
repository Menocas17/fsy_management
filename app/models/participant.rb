class Participant < ApplicationRecord
  enum :rol, { director: 0, coordinator: 1, coordinator_assistant: 2, company_leader: 3, logistic: 4, participant: 5 }
  enum :stake, { bello_horizonte: 0, las_americas: 1, villa_flor: 2, puerto_cabezas: 3 }
  enum :shirt_number, { xs: 0, s: 1, m: 2, l: 3, xl: 4 }
  enum :genre, { M: 0, H: 1 }

  validates :first_name, :last_name, :age, :stake, :shirt_number, :genre, presence: true
   validate :age_must_be_in_range

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
