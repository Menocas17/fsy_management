# El correo sale por el SMTP de Brevo (plan gratis: 300 correos al día). Va por el puerto 2525 porque el plan
# gratis de Render bloquea el 25, el 465 y el 587. Todo sale de variables de entorno (en Render, del panel
# Environment; ver docs/deploy_render.md):
#
#   SMTP_USERNAME  el "Login" de Brevo (algo como 8a1b2c001@smtp-brevo.com), no el correo de la cuenta
#   SMTP_PASSWORD  una SMTP key de Brevo (Settings → SMTP & API → SMTP)
#   MAILER_FROM    el remitente; tiene que estar verificado en Brevo (Senders, domains & IPs)
#   SMTP_ADDRESS, SMTP_PORT  solo para cambiar de proveedor
#
# Lo usan production.rb y, si se pide, development.rb (SMTP_EN_DESARROLLO=1).
module SmtpMail
  def self.settings
    {
      address: ENV.fetch("SMTP_ADDRESS", "smtp-relay.brevo.com"),
      port: ENV.fetch("SMTP_PORT", 2525).to_i,
      user_name: ENV["SMTP_USERNAME"],
      password: ENV["SMTP_PASSWORD"],
      authentication: :plain,
      enable_starttls_auto: true,
      open_timeout: 10,
      read_timeout: 15
    }
  end

  def self.from
    ENV["MAILER_FROM"].presence
  end

  def self.configured?
    [ settings[:user_name], settings[:password], from ].all?(&:present?)
  end
end
