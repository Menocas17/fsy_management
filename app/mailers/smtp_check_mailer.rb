# Solo para comprobar que la cuenta de correo funciona: bin/rails 'correo:prueba[destino]'.
class SmtpCheckMailer < ApplicationMailer
  skip_before_action :attach_mark
  def check(destination)
    mail(to: destination, subject: "[#{Rails.configuration.x.event_name}] Prueba de correo") do |format|
      format.text { render plain: "Si lees esto, la app ya puede mandar correos." }
    end
  end
end
