namespace :correo do
  desc "Manda un correo de prueba por la cuenta configurada: bin/rails correo:prueba[tu@correo.com]"
  task :prueba, [ :destino ] => :environment do |_, args|
    destino = args[:destino].presence || abort("Indica a quién: bin/rails correo:prueba[tu@correo.com]")
    require Rails.root.join("config/smtp_mail")
    if ActionMailer::Base.delivery_method != :smtp
      abort "Aquí los correos no salen por SMTP. En desarrollo: SMTP_EN_DESARROLLO=1 bin/rails correo:prueba[...]"
    end
    abort "Faltan SMTP_USERNAME, SMTP_PASSWORD o MAILER_FROM (ver config/smtp_mail.rb)" unless SmtpMail.configured?

    SmtpCheckMailer.check(destino).deliver_now
    puts "Enviado a #{destino} desde #{SmtpMail.from} por #{SmtpMail.settings[:address]}."
  end
end
