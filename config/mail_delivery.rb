require_relative "smtp_mail"
require_relative "apps_script_mail"

# Por dónde salen los correos de verdad: el Apps Script si está configurado (config/apps_script_mail.rb), si no
# el SMTP (config/smtp_mail.rb). Lo usan production.rb y, con CORREO_EN_DESARROLLO=1, development.rb.
module MailDelivery
  def self.delivery_method
    AppsScriptMail.configured? ? :apps_script : :smtp
  end

  def self.configured?
    delivery_method == :apps_script || SmtpMail.configured?
  end

  def self.apply(config)
    config.action_mailer.delivery_method = delivery_method
    config.action_mailer.smtp_settings = SmtpMail.settings if delivery_method == :smtp
    # Si el envío falla, el error queda en el log del job (Solid Queue) en vez de perderse en silencio.
    config.action_mailer.raise_delivery_errors = true
    config.x.mailer_from = SmtpMail.from
    # «¿Olvidaste tu contraseña?» solo aparece si de verdad hay con qué mandar el correo.
    config.x.password_reset_emails = configured?
  end
end
