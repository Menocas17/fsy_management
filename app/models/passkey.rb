# Una passkey: la llave que el teléfono (o la compu) guarda para entrar sin contraseña, desbloqueada con la
# huella, la cara o el PIN del dispositivo. Aquí solo vive su llave pública; la privada nunca sale del
# dispositivo (o de su llavero: iCloud o Google la pasan a los otros dispositivos de la misma persona).
class Passkey < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, :name, presence: true

  scope :recent_first, -> { order(Arel.sql("last_used_at DESC NULLS LAST"), created_at: :desc) }

  # Con quién se firma: el dominio de la app. En producción el configurado (APP_HOST o el de Render); en
  # desarrollo y en las pruebas, el de la petición (localhost o el túnel).
  def self.relying_party(request)
    host = Rails.env.production? ? (ENV["APP_HOST"].presence || ENV["RENDER_EXTERNAL_HOSTNAME"].presence || request.host) : request.host
    origin = Rails.env.production? ? "https://#{host}" : request.base_url
    WebAuthn::RelyingParty.new(id: host, allowed_origins: [ origin ], name: "FSY Management")
  end

  # El nombre con que se lista: el dispositivo donde se creó («iPhone · Safari»).
  def self.name_for(user_agent)
    DeviceLabel.for(user_agent).to_s.presence&.first(80) || "Este dispositivo"
  end

  # Anota que se usó y el contador de la llave (WebAuthn lo sube en cada firma para detectar copias).
  def used!(sign_count)
    update!(sign_count: sign_count, last_used_at: Time.current)
  end
end
