class Session < ApplicationRecord
  belongs_to :user

  # Una sesión sin uso en este tiempo se cierra sola; antes duraban para siempre.
  IDLE_LIMIT = 30.days
  # Y aunque se use a diario, una sesión no vive más que esto: el que entró una vez no queda adentro para siempre.
  MAX_AGE = 90.days
  # Cada cuánto se anota que la sesión sigue en uso (no en cada clic, para no escribir en cada request).
  SEEN_EVERY = 5.minutes
  # «En línea»: usó la app en este rato.
  ONLINE_WINDOW = 15.minutes

  scope :recent_first, -> { order(updated_at: :desc) }
  scope :online, -> { where(updated_at: ONLINE_WINDOW.ago..) }

  def expired?
    updated_at < IDLE_LIMIT.ago || created_at < MAX_AGE.ago
  end

  def online?
    updated_at >= ONLINE_WINDOW.ago
  end

  def seen!
    touch if updated_at < SEEN_EVERY.ago
  end

  def device_label
    DeviceLabel.for(user_agent)
  end
end
