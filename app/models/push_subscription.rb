# El permiso que da un navegador para recibir notificaciones, una fila por dispositivo.
# El endpoint lo emite el propio navegador y es la dirección a la que se envía el aviso.
class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh_key, :auth_key, presence: true

  scope :recent_first, -> { order(last_used_at: :desc, created_at: :desc) }

  # El navegador manda siempre el mismo endpoint para el mismo dispositivo: así no se duplican.
  def self.register!(user:, endpoint:, p256dh:, auth:, device: nil)
    subscription = find_or_initialize_by(endpoint: endpoint)
    subscription.update!(user: user, p256dh_key: p256dh, auth_key: auth,
                         device: device.presence&.truncate(120), last_used_at: Time.current)
    subscription
  end

  def push_params
    { endpoint: endpoint, keys: { p256dh: p256dh_key, auth: auth_key } }
  end
end
