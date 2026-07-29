class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :participant, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin_or_staff_manager?
    return true if participant_id.nil?
    participant&.coordinador? || participant&.director? || participant&.logistica?
  end

  def counselers_staff?
    participant&.consejero? || participant&.auxiliar?
  end
end
