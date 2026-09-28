# Un intento de inicio de sesión. Se guarda el correo tal cual se escribió (aunque no exista la cuenta),
# nunca la contraseña.
class LoginAttempt < ApplicationRecord
  belongs_to :user, optional: true

  enum :result, { success: 0, failed: 1, blocked: 2 }, prefix: true

  RESULT_LABELS = { "success" => "Entró", "failed" => "Contraseña o correo incorrectos", "blocked" => "Bloqueado por demasiados intentos" }.freeze
  KEEP_FOR = 90.days

  scope :recent, -> { order(created_at: :desc) }

  def self.record!(email:, result:, request:, user: nil)
    create!(email_address: email.to_s.strip.downcase.first(254), result: result, user: user,
            ip_address: request.remote_ip, user_agent: request.user_agent.to_s.first(500))
    # La tabla no crece sin fin: lo de hace más de tres meses ya no sirve para nada.
    where(created_at: ...KEEP_FOR.ago).delete_all if rand < 0.02
  end

  def device_label
    DeviceLabel.for(user_agent)
  end

  def result_label
    RESULT_LABELS.fetch(result, result)
  end
end
