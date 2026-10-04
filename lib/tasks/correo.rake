namespace :correo do
  desc "Manda un correo de prueba por la cuenta configurada: bin/rails correo:prueba[tu@correo.com]"
  task :prueba, [ :destino ] => :environment do |_, args|
    destino = args[:destino].presence || abort("Indica a quién: bin/rails correo:prueba[tu@correo.com]")
    require Rails.root.join("config/mail_delivery")
    unless ActionMailer::Base.delivery_method.in?(%i[ apps_script smtp ])
      abort "Aquí los correos no salen de verdad. En desarrollo: CORREO_EN_DESARROLLO=1 bin/rails correo:prueba[...]"
    end
    unless MailDelivery.configured?
      abort "Falta MAIL_RELAY_URL y MAIL_RELAY_SECRET (config/apps_script_mail.rb) o SMTP_USERNAME, SMTP_PASSWORD y MAILER_FROM (config/smtp_mail.rb)"
    end

    SmtpCheckMailer.check(destino).deliver_now
    via = ActionMailer::Base.delivery_method == :apps_script ? "el Apps Script" : SmtpMail.settings[:address]
    puts "Enviado a #{destino} por #{via}."
  end
end
