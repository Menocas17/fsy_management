namespace :correo do
  desc "Manda un correo de prueba por la cuenta configurada: bin/rails correo:prueba[tu@correo.com]"
  task :prueba, [ :destino ] => :environment do |_, args|
    destino = args[:destino].presence || abort("Indica a quién: bin/rails correo:prueba[tu@correo.com]")
    require Rails.root.join("config/gmail_smtp")
    if ActionMailer::Base.delivery_method != :smtp || ActionMailer::Base.smtp_settings[:address] != "smtp.gmail.com"
      abort "Aquí los correos no salen por Gmail. En desarrollo: SMTP_EN_DESARROLLO=1 bin/rails correo:prueba[...]"
    end
    abort "Faltan smtp.user_name o smtp.password en las credenciales (bin/rails credentials:edit)" unless GmailSmtp.configured?

    SmtpCheckMailer.check(destino).deliver_now
    puts "Enviado a #{destino} desde #{GmailSmtp.settings[:user_name]}."
  end
end
