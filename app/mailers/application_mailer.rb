class ApplicationMailer < ActionMailer::Base
  # El remitente es la cuenta de Gmail de la app (Gmail no deja enviar como otra dirección), con el nombre
  # del evento para que se reconozca en la bandeja de entrada.
  default from: -> { %("#{Rails.configuration.x.event_name}" <#{Rails.application.credentials.dig(:smtp, :user_name) || "no-responder@example.com"}>) }
  layout "mailer"

  # La marca del encabezado (layouts/mailer) va adjunta en línea: Gmail no muestra imágenes data: y una URL
  # al servidor depende de que esté en línea. Solo en los correos con versión HTML.
  before_action :attach_mark

  private
    def attach_mark
      attachments.inline["fsy-mark.png"] = Rails.root.join("app/assets/images/fsy-mark.png").binread
    end
end
