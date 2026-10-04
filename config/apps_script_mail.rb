# El correo sale por un Google Apps Script publicado como web app (docs/apps_script/mail_relay.gs), que lo
# manda desde el Gmail de quien lo publicó. Va por HTTPS: el plan gratis de Render bloquea los puertos de
# correo, y los proveedores SMTP gratis piden dominio propio o teléfono. Una cuenta normal de Gmail manda
# unos 100 correos al día así (Google Workspace, 1500). Variables de entorno (ver docs/deploy_render.md):
#
#   MAIL_RELAY_URL     la URL de la web app (https://script.google.com/macros/s/…/exec)
#   MAIL_RELAY_SECRET  la clave que el script espera (su propiedad SECRET)
#
# Con estas dos, gana sobre el SMTP de config/smtp_mail.rb. El remitente es siempre ese Gmail; del From del
# correo solo se usa el nombre. Lo usan production.rb y, si se pide, development.rb (CORREO_EN_DESARROLLO=1).
module AppsScriptMail
  def self.settings
    {
      url: ENV["MAIL_RELAY_URL"].presence,
      secret: ENV["MAIL_RELAY_SECRET"].presence
    }
  end

  def self.configured?
    settings.values.all?(&:present?)
  end
end
