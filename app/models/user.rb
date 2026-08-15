class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :participant, optional: true

  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :password_complexity

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin_or_staff_manager?
    return true if participant_id.nil?
    participant&.coordinador? || participant&.director? || participant&.logistica?
  end

  def counselers_staff?
    participant&.consejero? || participant&.auxiliar?
  end

  def full_name
    participant&.full_name || "Super Administrado"
  end

  def rol
    participant&.rol || "superadmin"
  end

  private
  def password_complexity
    return if password.blank?

    unless password.match?(/\d/)
      errors.add :password, "debe incluir al menos un número."
    end

    unless password.match?(/[A-Z]/)
      errors.add :password, "debe incluir al menos una letra mayúscula."
    end

    unless password.match?(/[[:punct:]]/)
      errors.add :password, "debe incluir al menos un carácter especial."
    end
  end
end
