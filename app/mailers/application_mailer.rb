class ApplicationMailer < ActionMailer::Base
  # El remitente es el verificado en Brevo (MAILER_FROM, ver config/smtp_mail.rb), con el nombre del evento
  # para que se reconozca en la bandeja de entrada.
  default from: -> { %("#{Rails.configuration.x.event_name}" <#{Rails.configuration.x.mailer_from || "no-responder@example.com"}>) }
  layout "mailer"

  # La marca del encabezado (layouts/mailer) va adjunta en línea: Gmail no muestra imágenes data: y una URL
  # al servidor depende de que esté en línea. Solo en los correos con versión HTML.
  before_action :attach_mark

  private
    def attach_mark
      attachments.inline["fsy-mark.png"] = Rails.root.join("app/assets/images/fsy-mark.png").binread
    end
end
