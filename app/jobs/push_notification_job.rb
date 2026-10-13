require "web_push"

# Envía una alerta a los dispositivos suscritos. Va en segundo plano porque cada dispositivo
# es una petición a su propio servidor de push (Google, Apple, Mozilla…).
class PushNotificationJob < ApplicationJob
  queue_as :default

  PRIORITY_PREFIX = { "critica" => "🔴 ", "importante" => "🟠 " }.freeze

  def perform(alert_id)
    alert = Alert.find_by(id: alert_id)
    return if alert.nil?

    subscriptions = PushSubscription.where(user: alert.push_recipients).includes(:user)
    subscriptions.find_each { |subscription| deliver(subscription, alert) }
  end

  # Un aviso a un dispositivo. Devuelve nil si salió, o por qué no (también lo usa la prueba de Configuración,
  # PushSubscriptionsController#test, para mostrarle a la persona qué contestó el servidor de push).
  def self.deliver(subscription, message, urgency: "normal")
    WebPush.payload_send(
      message: message.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: vapid,
      urgency: urgency,
      ttl: 12.hours.to_i
    )
    subscription.update_column(:last_used_at, Time.current)
    nil
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription => error
    # El navegador ya no quiere saber nada de este endpoint: se borra y no se reintenta.
    subscription.destroy
    "#{error.class.name.demodulize}: el teléfono ya no acepta este registro"
  rescue WebPush::ResponseError => error
    Rails.logger.warn("Push rechazado para #{subscription.id}: #{error.class} #{error.message}")
    "#{error.class.name.demodulize} #{error.response&.code}: #{error.response&.body.to_s.truncate(160)}"
  rescue StandardError => error
    Rails.logger.warn("Push falló para #{subscription.id}: #{error.class} #{error.message}")
    "#{error.class}: #{error.message.truncate(160)}"
  end

  def self.vapid
    {
      public_key: Rails.application.credentials.dig(:vapid, :public_key),
      private_key: Rails.application.credentials.dig(:vapid, :private_key),
      subject: Rails.application.config.x.push_subject
    }
  end

  private
    def deliver(subscription, alert)
      self.class.deliver(subscription, payload(alert), urgency: alert.priority_critica? ? "high" : "normal")
    end

    def payload(alert)
      {
        title: "#{PRIORITY_PREFIX[alert.priority.to_s]}#{alert.title}",
        options: {
          body: alert.body.to_s.truncate(160),
          icon: "/icon-192.png",
          badge: "/icon.png",
          tag: "alert-#{alert.id}",
          renotify: alert.priority_critica?,
          requireInteraction: alert.priority_critica?,
          # Android respeta esta vibración; en iPhone el sonido lo gobierna el sistema.
          vibrate: alert.priority_critica? ? [ 100, 60, 100, 60, 200 ] : [ 90, 60, 90 ],
          silent: false,
          data: { path: alert.link_path.presence || "/alertas/#{alert.id}", priority: alert.priority }
        }
      }
    end
end
