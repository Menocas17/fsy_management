class ApplicationMailer < ActionMailer::Base
  # El remitente es la cuenta de Gmail de la app (Gmail no deja enviar como otra dirección), con el nombre
  # del evento para que se reconozca en la bandeja de entrada.
  default from: -> { %("#{Rails.configuration.x.event_name}" <#{Rails.application.credentials.dig(:smtp, :user_name) || "no-responder@example.com"}>) }
  layout "mailer"
end
